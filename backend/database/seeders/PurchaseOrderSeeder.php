<?php

namespace Database\Seeders;

use App\Models\Inventory;
use App\Models\InventoryTransaction;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\Store;
use App\Models\Supplier;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class PurchaseOrderSeeder extends Seeder
{
    public function run(): void
    {
        $stores = Store::query()->where('status', 1)->get();
        $suppliers = Supplier::query()->where('status', 1)->get()->keyBy('name');
        $products = Product::query()->where('status', 1)->get()->keyBy('name');

        if ($stores->isEmpty() || $products->isEmpty()) {
            $this->command->warn('请先运行 DemoDataSeeder 生成门店和商品数据。');

            return;
        }

        $supA = $suppliers->get('新鲜直送农场');
        $supB = $suppliers->get('港鲜肉类批发');
        $supC = $suppliers->get('南海水产行');

        // 固定每日必进商品
        $dailyItems = [
            ['胡萝卜',   $supA, 1.2,  30],
            ['白菜',     $supA, 0.8,  40],
            ['番茄',     $supA, 2.5,  25],
            ['土豆',     $supA, 1.0,  35],
            ['猪五花肉', $supB, 18.0, 10],
            ['鸡胸肉',   $supB, 12.5, 12],
            ['鲈鱼',     $supC, 28.0,  8],
            ['豆腐',     $supA, 2.5,  20],
        ];

        // 每天轮换 2 种补货
        $rotating = [
            [['西兰花', $supA, 3.5, 20], ['基围虾', $supC, 65.0, 5]],
            [['青椒',   $supA, 2.8, 15], ['苹果',   $supA,  4.5, 20]],
            [['洋葱',   $supA, 1.5, 20], ['香蕉',   $supA,  3.2, 15]],
            [['橙子',   $supA, 3.8, 18], ['猪排骨', $supB, 22.0, 8]],
            [['豆芽',   $supA, 1.8, 20], ['花蛤',   $supC, 12.0, 12]],
        ];

        $seqCounters = [];
        $created = 0;

        // 5 天：前 3 天已收货，昨天配送中，今天草稿
        for ($daysAgo = 4; $daysAgo >= 0; $daysAgo--) {
            $date = now()->subDays($daysAgo)->toDateString();
            $dateKey = str_replace('-', '', $date);

            $status = match ($daysAgo) {
                0 => 1, // 今天 草稿
                1 => 4, // 昨天 配送中
                default => 5, // 更早 已收货
            };

            $dayItems = array_merge($dailyItems, $rotating[$daysAgo % 5]);

            foreach ($stores as $store) {
                $exists = PurchaseOrder::query()
                    ->where('store_id', $store->id)
                    ->whereDate('expected_delivery_date', $date)
                    ->exists();

                if ($exists) {
                    continue;
                }

                $seqCounters[$dateKey] = ($seqCounters[$dateKey] ?? 0) + 1;
                $orderNo = 'PO-'.$dateKey.'-'.str_pad($seqCounters[$dateKey], 5, '0', STR_PAD_LEFT);

                $order = PurchaseOrder::create([
                    'store_id' => $store->id,
                    'supplier_id' => null,
                    'order_no' => $orderNo,
                    'order_type' => 2,
                    'status' => $status,
                    'expected_delivery_date' => $date,
                    'actual_delivery_date' => $status === 5 ? $date : null,
                    'total_amount' => 0,
                    'created_by' => 1,
                    'created_at' => Carbon::parse($date)->setTime(7, rand(0, 30)),
                    'updated_at' => Carbon::parse($date)->setTime(8, rand(0, 59)),
                ]);

                $totalAmount = 0;

                foreach ($dayItems as [$productName, $supplier, $unitPrice, $baseQty]) {
                    if (! $products->has($productName)) {
                        continue;
                    }

                    $qty = round($baseQty * (0.7 + lcg_value() * 0.6), 1);
                    $total = round($qty * $unitPrice, 2);
                    $totalAmount += $total;

                    PurchaseOrderItem::create([
                        'purchase_order_id' => $order->id,
                        'product_id' => $products[$productName]->id,
                        'supplier_id' => $supplier?->id,
                        'ordered_qty' => $qty,
                        'received_qty' => $status === 5 ? $qty : 0,
                        'unit_price' => $unitPrice,
                        'total_price' => $total,
                    ]);

                    if ($status === 5) {
                        $this->applyToInventory(
                            $store->id,
                            $products[$productName]->id,
                            $qty,
                            $unitPrice,
                            $order,
                            Carbon::parse($date)->setTime(9, rand(0, 59))
                        );
                    }
                }

                $order->update(['total_amount' => $totalAmount]);
                $created++;
            }
        }

        $this->command->info("✅ 进货单演示数据：共创建 {$created} 张（5 天 × {$stores->count()} 门店）");
    }

    private function applyToInventory(
        int $storeId,
        int $productId,
        float $qty,
        float $unitPrice,
        PurchaseOrder $order,
        Carbon $receivedAt
    ): void {
        $inventory = Inventory::firstOrCreate(
            ['store_id' => $storeId, 'product_id' => $productId],
            ['current_qty' => 0, 'available_qty' => 0, 'locked_qty' => 0]
        );

        $qtyBefore = (float) $inventory->current_qty;
        $qtyAfter = $qtyBefore + $qty;

        InventoryTransaction::create([
            'store_id' => $storeId,
            'product_id' => $productId,
            'transaction_type' => 1,
            'qty_change' => $qty,
            'qty_before' => $qtyBefore,
            'qty_after' => $qtyAfter,
            'unit_cost' => $unitPrice,
            'total_cost' => round($qty * $unitPrice, 2),
            'reference_type' => 'purchase_order',
            'reference_id' => $order->id,
            'notes' => "进货单 {$order->order_no}",
            'operator_id' => 1,
            'created_at' => $receivedAt,
        ]);

        $inventory->update([
            'current_qty' => $qtyAfter,
            'available_qty' => $qtyAfter,
            'last_in_at' => $receivedAt,
        ]);
    }
}
