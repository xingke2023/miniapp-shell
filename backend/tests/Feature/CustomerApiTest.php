<?php

use App\Models\Customer;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

// crmActor() 定义在 tests/Pest.php（全局共用）。

it('创建顾客并按门店归属', function () {
    [$user, $store, $bearer] = crmActor();

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customers', [
            'name' => '张三',
            'phone' => '13800138000',
            'level' => 2,
            'tags' => ['高频', '批发'],
        ]);

    $res->assertStatus(201)
        ->assertJsonPath('data.name', '张三')
        ->assertJsonPath('data.store_id', $store->id);

    $c = Customer::first();
    expect($c->store_id)->toBe($store->id);
    expect($c->created_by)->toBe($user->id);
    expect($c->tags)->toBe(['高频', '批发']);
});

it('同店手机号重复时返回 409', function () {
    [$user, $store, $bearer] = crmActor();
    Customer::factory()->create(['store_id' => $store->id, 'phone' => '13800138000']);

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customers', ['name' => '李四', 'phone' => '13800138000'])
        ->assertStatus(409);
});

it('未关联门店时回退到默认门店（暂不区分门店）', function () {
    // 准备一个门店并设为默认门店
    [$seedUser, $defaultStore] = crmActor();
    config(['store.default_id' => $defaultStore->id]);

    // 该用户无任何门店关联、token 也无 store ability
    $user = User::factory()->create();
    $bearer = $user->createToken('test', [])->plainTextToken;

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customers', ['name' => '王五']);

    $res->assertStatus(201)
        ->assertJsonPath('data.store_id', $defaultStore->id);
});

it('顾客列表只返回本店数据（跨店隔离）', function () {
    [$userA, $storeA, $bearerA] = crmActor(1);
    [$userB, $storeB, $bearerB] = crmActor(2);

    Customer::factory()->create(['store_id' => $storeA->id, 'name' => 'A店顾客']);
    Customer::factory()->create(['store_id' => $storeB->id, 'name' => 'B店顾客']);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearerA)
        ->getJson('/api/customers');

    $res->assertOk();
    expect($res->json('total'))->toBe(1);
    expect($res->json('data.0.name'))->toBe('A店顾客');
});

it('支持按姓名/手机搜索与标签过滤', function () {
    [$user, $store, $bearer] = crmActor();
    Customer::factory()->create(['store_id' => $store->id, 'name' => '陈大文', 'phone' => '13900001111', 'tags' => ['VIP']]);
    Customer::factory()->create(['store_id' => $store->id, 'name' => '林小明', 'phone' => '13700002222', 'tags' => ['普通']]);

    $byName = $this->withHeader('Authorization', 'Bearer '.$bearer)->getJson('/api/customers?q=陈大文');
    expect($byName->json('total'))->toBe(1);

    $byTag = $this->withHeader('Authorization', 'Bearer '.$bearer)->getJson('/api/customers?tag=VIP');
    expect($byTag->json('total'))->toBe(1);
    expect($byTag->json('data.0.name'))->toBe('陈大文');
});

it('新增并查询顾客跟进记录', function () {
    [$user, $store, $bearer] = crmActor();
    $customer = Customer::factory()->create(['store_id' => $store->id]);

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson("/api/customers/{$customer->id}/follow-ups", [
            'type' => 1,
            'content' => '电话回访，意向复购',
        ])->assertStatus(201);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->getJson("/api/customers/{$customer->id}/follow-ups");

    $res->assertOk();
    expect($res->json('data'))->toHaveCount(1);
    expect($res->json('data.0.content'))->toBe('电话回访，意向复购');
    expect($res->json('data.0.operator_id'))->toBe($user->id);
});
