<?php

use App\Models\Organization;
use App\Models\SalesDailySummary;
use App\Models\SalesOrder;
use App\Models\SalesUpload;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

uses(RefreshDatabase::class);

/** 建好「上报人 + 门店 + token(带 store ability)」，返回 [user, store, bearer]。 */
function salesActor(): array
{
    // SalesUploadService 写库走 Product::findOrCreateByName(org 1)，强制 org id=1
    $org = new Organization(['name' => '测试组织', 'code' => 'ORG'.fake()->unique()->numerify('###')]);
    $org->id = 1;
    $org->save();
    $store = Store::create([
        'organization_id' => $org->id, 'region_id' => null,
        'name' => '测试门店', 'code' => 'ST'.fake()->unique()->numerify('###'), 'status' => 1,
    ]);
    $user = User::factory()->create();
    $bearer = $user->createToken('test', ['store:'.$store->id])->plainTextToken;

    return [$user, $store, $bearer];
}

/** 桩掉 deepseek-4-pro：/chat/completions 返回固定识别明细。 */
function fakeDeepseek(array $items, string $summary = '识别成功'): void
{
    Http::fake([
        '*/chat/completions' => Http::response([
            'choices' => [['message' => ['content' => json_encode(['items' => $items, 'summary' => $summary])]]],
        ]),
    ]);
}

it('识别图片只返回明细、不写销售', function () {
    Storage::fake('local');
    fakeDeepseek([
        ['product_name' => '番茄', 'qty' => 5, 'amount' => 30, 'unit' => '斤'],
        ['product_name' => '黄瓜', 'qty' => 3, 'amount' => 12, 'unit' => '斤'],
    ]);
    [, $store, $bearer] = salesActor();

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->post('/api/sales/upload/recognize', [
            'file' => UploadedFile::fake()->create('sales.jpg', 100, 'image/jpeg'),
        ], ['Accept' => 'application/json']);

    $res->assertOk()
        ->assertJsonCount(2, 'items')
        ->assertJsonPath('items.0.product_name', '番茄');

    // 识别阶段绝不写销售
    expect(SalesOrder::count())->toBe(0);
    $upload = SalesUpload::first();
    expect($upload->status)->toBe(SalesUpload::STATUS_PENDING);
    expect($upload->store_id)->toBe($store->id);
});

it('确认后写入今日销售补录并扣库存', function () {
    [$user, $store, $bearer] = salesActor();

    $upload = SalesUpload::create([
        'store_id' => $store->id, 'uploaded_by' => $user->id,
        'original_filename' => 'sales.jpg', 'file_path' => 'x.jpg',
        'sale_date' => today()->toDateString(), 'status' => SalesUpload::STATUS_PENDING,
    ]);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson("/api/sales/upload/{$upload->id}/commit", [
            'items' => [
                ['product_name' => '土豆', 'qty' => 4, 'amount' => 16, 'unit' => '斤'],
                ['product_name' => '茄子', 'qty' => 2, 'amount' => 10, 'unit' => '斤'],
            ],
        ]);

    $res->assertOk()->assertJson(['processed' => 2, 'failed' => 0]);

    expect(SalesOrder::where('store_id', $store->id)->count())->toBe(2);
    expect(SalesDailySummary::where('store_id', $store->id)->count())->toBe(2);
    expect($upload->fresh()->status)->toBe(SalesUpload::STATUS_COMPLETED);
});

it('不支持的文件类型返回 422', function () {
    Storage::fake('local');
    [, , $bearer] = salesActor();

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->post('/api/sales/upload/recognize', [
            'file' => UploadedFile::fake()->create('note.txt', 10, 'text/plain'),
        ], ['Accept' => 'application/json'])
        ->assertStatus(422)
        ->assertJsonValidationErrors(['file']);
});

it('commit 空 items 返回 422', function () {
    [$user, $store, $bearer] = salesActor();
    $upload = SalesUpload::create([
        'store_id' => $store->id, 'uploaded_by' => $user->id,
        'original_filename' => 'x', 'file_path' => 'x',
        'sale_date' => today()->toDateString(), 'status' => SalesUpload::STATUS_PENDING,
    ]);

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson("/api/sales/upload/{$upload->id}/commit", ['items' => []])
        ->assertStatus(422)
        ->assertJsonValidationErrors(['items']);
});
