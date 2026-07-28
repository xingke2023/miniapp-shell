<?php

use App\Filament\Resources\CustomerOrderResource\Pages\ListCustomerOrders;
use App\Filament\Resources\CustomerResource\Pages\ListCustomers;
use App\Models\Customer;
use App\Models\CustomerOrder;
use App\Models\Organization;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;

uses(RefreshDatabase::class);

function seedCrm(): array
{
    $org = Organization::create(['name' => '组织', 'code' => 'ORG'.fake()->unique()->numerify('###')]);
    $store = Store::create([
        'organization_id' => $org->id, 'region_id' => null,
        'name' => '中环店', 'code' => 'ST'.fake()->unique()->numerify('###'), 'status' => 1,
    ]);

    $vip = Customer::factory()->create(['store_id' => $store->id, 'name' => '金卡客户', 'level' => 3, 'status' => 1]);
    Customer::factory()->create(['store_id' => $store->id, 'name' => '普通客户', 'level' => 1, 'status' => 1]);

    return [$store, $vip];
}

it('顾客档案页正常渲染并显示记录', function () {
    [$store] = seedCrm();
    $admin = User::factory()->create(['is_admin' => true]);

    Livewire::actingAs($admin)
        ->test(ListCustomers::class)
        ->assertOk()
        ->assertCanSeeTableRecords(Customer::all());
});

it('可按会员等级过滤顾客', function () {
    [$store] = seedCrm();
    $admin = User::factory()->create(['is_admin' => true]);

    Livewire::actingAs($admin)
        ->test(ListCustomers::class)
        ->filterTable('level', 3)
        ->assertCanSeeTableRecords(Customer::where('level', 3)->get())
        ->assertCanNotSeeTableRecords(Customer::where('level', 1)->get());
});

it('顾客订单页正常渲染', function () {
    [$store, $vip] = seedCrm();
    $admin = User::factory()->create(['is_admin' => true]);

    $order = CustomerOrder::factory()->create([
        'store_id' => $store->id, 'customer_id' => $vip->id, 'status' => 1, 'total_amount' => 100,
    ]);

    Livewire::actingAs($admin)
        ->test(ListCustomerOrders::class)
        ->assertOk()
        ->assertCanSeeTableRecords(CustomerOrder::all());
});

it('订单更新状态为已完成时累计顾客消费', function () {
    [$store, $vip] = seedCrm();
    $admin = User::factory()->create(['is_admin' => true]);

    $order = CustomerOrder::factory()->create([
        'store_id' => $store->id, 'customer_id' => $vip->id, 'status' => 1, 'total_amount' => 100,
    ]);

    Livewire::actingAs($admin)
        ->test(ListCustomerOrders::class)
        ->callTableAction('updateStatus', $order, ['status' => 4]);

    $vip->refresh();
    expect((float) $vip->total_spent)->toBe(100.0);
    expect($vip->order_count)->toBe(1);
    expect((int) CustomerOrder::find($order->id)->status)->toBe(4);
});
