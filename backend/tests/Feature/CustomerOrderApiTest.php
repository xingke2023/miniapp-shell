<?php

use App\Models\Customer;
use App\Models\CustomerOrder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

// 复用 CustomerApiTest.php 中定义的 crmActor() 全局函数。

it('创建订单并按明细汇总金额、生成单号', function () {
    [$user, $store, $bearer] = crmActor();
    $customer = Customer::factory()->create(['store_id' => $store->id, 'name' => '赵六']);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customer-orders', [
            'customer_id' => $customer->id,
            'type' => 2,
            'discount_amount' => 5,
            'items' => [
                ['product_name' => '番茄', 'qty' => 3, 'unit' => '斤', 'unit_price' => 5],
                ['product_name' => '白菜', 'qty' => 2, 'unit' => '斤', 'unit_price' => 4],
            ],
        ]);

    // 小计 15 + 8 = 23，减折扣 5 = 18
    $res->assertStatus(201)
        ->assertJsonPath('data.total_amount', '18.00')
        ->assertJsonPath('data.customer_name', '赵六');

    $order = CustomerOrder::first();
    expect($order->order_no)->toStartWith('CO-');
    expect($order->store_id)->toBe($store->id);
    expect($order->items()->count())->toBe(2);
});

it('订单完成时累计顾客消费、订单数与积分', function () {
    [$user, $store, $bearer] = crmActor();
    $customer = Customer::factory()->create(['store_id' => $store->id, 'total_spent' => 0, 'order_count' => 0, 'points' => 0]);

    $create = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customer-orders', [
            'customer_id' => $customer->id,
            'items' => [['product_name' => '苹果', 'qty' => 10, 'unit_price' => 6]],
        ]);
    $orderId = $create->json('data.id'); // 总额 60

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->putJson("/api/customer-orders/{$orderId}/status", ['status' => 4])
        ->assertOk();

    $customer->refresh();
    expect((float) $customer->total_spent)->toBe(60.0);
    expect($customer->order_count)->toBe(1);
    expect($customer->points)->toBe(60);
});

it('重复置为已完成不会重复计入消费', function () {
    [$user, $store, $bearer] = crmActor();
    $customer = Customer::factory()->create(['store_id' => $store->id]);
    $orderId = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customer-orders', [
            'customer_id' => $customer->id,
            'items' => [['product_name' => '梨', 'qty' => 5, 'unit_price' => 4]],
        ])->json('data.id'); // 20

    $put = fn () => $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->putJson("/api/customer-orders/{$orderId}/status", ['status' => 4]);
    $put();
    $put(); // 第二次不应再加

    $customer->refresh();
    expect((float) $customer->total_spent)->toBe(20.0);
    expect($customer->order_count)->toBe(1);
});

it('取消订单不计入消费', function () {
    [$user, $store, $bearer] = crmActor();
    $customer = Customer::factory()->create(['store_id' => $store->id]);
    $orderId = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/customer-orders', [
            'customer_id' => $customer->id,
            'items' => [['product_name' => '橙', 'qty' => 5, 'unit_price' => 4]],
        ])->json('data.id');

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->putJson("/api/customer-orders/{$orderId}/status", ['status' => 5])
        ->assertOk();

    $customer->refresh();
    expect((float) $customer->total_spent)->toBe(0.0);
    expect($customer->order_count)->toBe(0);
});

it('不能给非本店顾客建订单', function () {
    [$userA, $storeA, $bearerA] = crmActor(1);
    [$userB, $storeB, $bearerB] = crmActor(2);
    $customerB = Customer::factory()->create(['store_id' => $storeB->id]);

    $this->withHeader('Authorization', 'Bearer '.$bearerA)
        ->postJson('/api/customer-orders', [
            'customer_id' => $customerB->id,
            'items' => [['product_name' => 'X', 'qty' => 1, 'unit_price' => 1]],
        ])->assertStatus(422);
});
