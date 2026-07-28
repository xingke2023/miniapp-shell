<?php

use App\Models\DamageRecord;
use App\Models\Inventory;
use App\Models\Organization;
use App\Models\Product;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

/**
 * 建好「上报人 + 门店 + token(带 store ability)」，返回 [user, store, bearer]。
 * 批量接口的 store_id/operator_id 都从该 token 解析。
 */
function damageActor(): array
{
    // 控制器 Product::findOrCreateByName 硬编码 organization_id=1，故强制建 org id=1
    $org = new Organization(['name' => '测试组织', 'code' => 'ORG'.fake()->unique()->numerify('###')]);
    $org->id = 1;
    $org->save();
    $store = Store::create([
        'organization_id' => $org->id,
        'region_id' => null,
        'name' => '测试门店',
        'code' => 'ST'.fake()->unique()->numerify('###'),
        'status' => 1,
    ]);
    $user = User::factory()->create();
    $bearer = $user->createToken('test', ['store:'.$store->id])->plainTextToken;

    return [$user, $store, $bearer];
}

it('批量录入多条损耗并扣减库存', function () {
    [$user, $store, $bearer] = damageActor();

    // 预置一个商品 + 库存 10，验证扣减
    $tomato = Product::create(['organization_id' => 1, 'name' => '番茄ABC', 'unit' => '斤', 'is_fresh' => true, 'status' => 1]);
    Inventory::create(['store_id' => $store->id, 'product_id' => $tomato->id, 'current_qty' => 10, 'available_qty' => 10, 'locked_qty' => 0]);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/damage/batch', [
            'items' => [
                ['product_name' => '番茄ABC', 'qty' => 3, 'reason' => '变质', 'occurred_at' => '2026-05-31 09:00:00'],
                ['product_name' => '大白菜XYZ', 'qty' => 2, 'reason' => '运输损坏', 'notes' => '整箱压坏'],
            ],
        ]);

    $res->assertStatus(201)
        ->assertJson(['total' => 2, 'success' => 2, 'failed' => 0]);

    expect(DamageRecord::where('store_id', $store->id)->count())->toBe(2);

    // 库存被扣减：10 - 3 = 7
    expect((float) Inventory::where('store_id', $store->id)->where('product_id', $tomato->id)->value('current_qty'))->toBe(7.0);

    // 门店 + 上报人按 token 写入
    $rec = DamageRecord::where('store_id', $store->id)->where('reason', '变质')->first();
    expect($rec->operator_id)->toBe($user->id);
    expect($rec->store_id)->toBe($store->id);
});

it('某条缺商品名时整批校验失败 422', function () {
    [, , $bearer] = damageActor();

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/damage/batch', [
            'items' => [
                ['product_name' => '番茄ABC', 'qty' => 3, 'reason' => '变质'],
                ['qty' => 2, 'reason' => '过期'], // 缺 product_name
            ],
        ])
        ->assertStatus(422)
        ->assertJsonValidationErrors(['items.1.product_name']);
});

it('账号未关联门店时回退默认门店（暂不区分门店）', function () {
    // 预置默认门店（damageActor 建 org id=1 + 门店）
    [$seedUser, $defaultStore] = damageActor();
    config(['store.default_id' => $defaultStore->id]);

    // token 不带 store ability，且无 user_store_roles → resolveStoreId() 回退默认门店
    $user = User::factory()->create();
    $bearer = $user->createToken('test', [])->plainTextToken;

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/damage/batch', [
            'items' => [['product_name' => '番茄ABC', 'qty' => 3, 'reason' => '变质']],
        ]);

    $res->assertStatus(201)->assertJson(['success' => 1]);
    expect(DamageRecord::where('store_id', $defaultStore->id)->count())->toBe(1);
});
