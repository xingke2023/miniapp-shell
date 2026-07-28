<?php

use App\Models\Inventory;
use App\Models\Organization;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

uses(RefreshDatabase::class);

function purchaseActor(): array
{
    // 写库走 Product::findOrCreateByName(org 1)，强制 org id=1
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

function fakeRecognizer(array $items, string $summary = '识别成功'): void
{
    Http::fake([
        '*/chat/completions' => Http::response([
            'choices' => [['message' => ['content' => json_encode(['items' => $items, 'summary' => $summary])]]],
        ]),
    ]);
}

it('识别进货图片只返回明细、不建单', function () {
    Storage::fake('public');
    fakeRecognizer([
        ['product_name' => '番茄', 'ordered_qty' => 50, 'unit_price' => 3.5, 'unit' => '斤'],
        ['product_name' => '黄瓜', 'ordered_qty' => 30, 'unit_price' => 2, 'unit' => '斤'],
    ]);
    [, , $bearer] = purchaseActor();

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->post('/api/purchase-orders/recognize', [
            'file' => UploadedFile::fake()->create('po.jpg', 100, 'image/jpeg'),
        ], ['Accept' => 'application/json']);

    $res->assertOk()
        ->assertJsonCount(2, 'items')
        ->assertJsonPath('items.0.product_name', '番茄')
        ->assertJsonCount(1, 'image_paths'); // 图片留存

    expect(PurchaseOrder::count())->toBe(0); // 识别阶段不建单
});

it('确认后建进货单、加库存、存单据图', function () {
    [, $store, $bearer] = purchaseActor();

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/purchase-orders', [
            'date' => today()->toDateString(),
            'image_paths' => ['/storage/purchase_uploads/x.jpg'],
            'items' => [
                ['product_name' => '土豆', 'ordered_qty' => 20, 'unit_price' => 2.5, 'unit' => '斤'],
                ['product_name' => '茄子', 'ordered_qty' => 10, 'unit_price' => 4, 'unit' => '斤'],
            ],
        ]);

    $res->assertStatus(201)->assertJsonPath('message', '进货单已创建并完成收货');

    $order = PurchaseOrder::where('store_id', $store->id)->first();
    expect($order->status)->toBe(5);                                  // 已收货
    expect($order->image_paths)->toBe(['/storage/purchase_uploads/x.jpg']);
    expect($order->items()->count())->toBe(2);

    // 库存增加：土豆 20
    $potato = Product::where('name', '土豆')->first();
    expect((float) Inventory::where('store_id', $store->id)->where('product_id', $potato->id)->value('current_qty'))->toBe(20.0);
});

it('不支持的文件类型返回 422', function () {
    Storage::fake('local');
    [, , $bearer] = purchaseActor();

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->post('/api/purchase-orders/recognize', [
            'file' => UploadedFile::fake()->create('note.txt', 10, 'text/plain'),
        ], ['Accept' => 'application/json'])
        ->assertStatus(422)
        ->assertJsonValidationErrors(['file']);
});
