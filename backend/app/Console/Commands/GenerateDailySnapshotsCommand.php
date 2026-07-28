<?php

namespace App\Console\Commands;

use App\Models\Inventory;
use App\Models\InventoryDailySnapshot;
use Illuminate\Console\Command;

class GenerateDailySnapshotsCommand extends Command
{
    protected $signature = 'inventory:generate-snapshots {date? : 日期 YYYY-MM-DD，默认今天}';

    protected $description = '为所有门店所有商品生成每日库存快照（无交易的商品用当前库存补充）';

    public function handle(): int
    {
        $date = $this->argument('date') ?? today()->toDateString();

        $inventories = Inventory::all();

        $created = 0;

        foreach ($inventories as $inventory) {
            $exists = InventoryDailySnapshot::where('store_id', $inventory->store_id)
                ->where('product_id', $inventory->product_id)
                ->where('date', $date)
                ->exists();

            if ($exists) {
                continue;
            }

            $qty = (float) $inventory->current_qty;

            InventoryDailySnapshot::create([
                'store_id' => $inventory->store_id,
                'product_id' => $inventory->product_id,
                'date' => $date,
                'opening_qty' => $qty,
                'received_qty' => 0,
                'sold_qty' => 0,
                'damage_qty' => 0,
                'adjustment_qty' => 0,
                'closing_qty' => $qty,
                'sold_out_at' => null,
            ]);

            $created++;
        }

        $this->info("[$date] 生成快照 {$created} 条，已有记录跳过 " . ($inventories->count() - $created) . ' 条');

        return self::SUCCESS;
    }
}
