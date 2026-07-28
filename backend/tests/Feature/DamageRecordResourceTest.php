<?php

use App\Filament\Resources\DamageRecordResource\Pages\ListDamageRecords;
use App\Models\DamageRecord;
use App\Models\Organization;
use App\Models\Product;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;

uses(RefreshDatabase::class);

function seedDamage(): array
{
    $org = Organization::create(['name' => '组织', 'code' => 'ORG'.fake()->unique()->numerify('###')]);
    $store = Store::create([
        'organization_id' => $org->id, 'region_id' => null,
        'name' => '中环店', 'code' => 'ST'.fake()->unique()->numerify('###'), 'status' => 1,
    ]);
    $product = Product::create(['organization_id' => $org->id, 'name' => '番茄DR', 'unit' => '斤', 'is_fresh' => true, 'status' => 1]);

    DamageRecord::create([
        'store_id' => $store->id, 'product_id' => $product->id, 'qty' => 3,
        'reason' => '变质', 'status' => 1, 'occurred_at' => '2026-05-30 10:00:00',
    ]);
    DamageRecord::create([
        'store_id' => $store->id, 'product_id' => $product->id, 'qty' => 5,
        'reason' => '运输损坏', 'total_claimed' => 25, 'status' => 2, 'occurred_at' => '2026-05-31 11:00:00',
    ]);

    return [$store, $product];
}

it('损耗统计页正常渲染并显示记录', function () {
    [$store] = seedDamage();
    $admin = User::factory()->create(['is_admin' => true]);

    Livewire::actingAs($admin)
        ->test(ListDamageRecords::class)
        ->assertOk()
        ->assertCanSeeTableRecords(DamageRecord::all());
});

it('可按门店与日期过滤损耗记录', function () {
    [$store] = seedDamage();
    $admin = User::factory()->create(['is_admin' => true]);

    Livewire::actingAs($admin)
        ->test(ListDamageRecords::class)
        ->filterTable('occurred_at', ['from' => '2026-05-31', 'until' => '2026-05-31'])
        ->assertCanSeeTableRecords(DamageRecord::where('reason', '运输损坏')->get())
        ->assertCanNotSeeTableRecords(DamageRecord::where('reason', '变质')->get());
});
