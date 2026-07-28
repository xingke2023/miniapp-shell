<?php

namespace Database\Seeders;

use App\Models\Expense;
use App\Models\ExpenseCategory;
use App\Models\Inventory;
use App\Models\InventoryTransaction;
use App\Models\Organization;
use App\Models\Product;
use App\Models\ProductCategory;
use App\Models\Store;
use App\Models\Supplier;
use App\Models\SupplierProduct;
use Illuminate\Database\Seeder;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $org = Organization::first();

        // ──────────── 门店 ────────────
        $storeXiWan = Store::firstOrCreate(
            ['code' => 'XWH'],
            ['organization_id' => $org->id, 'region_id' => 1, 'name' => '西湾河店', 'address' => '西湾河筲箕湾道 18 号地铺', 'status' => 1]
        );

        $storeWanChai = Store::firstOrCreate(
            ['code' => 'WCH'],
            ['organization_id' => $org->id, 'region_id' => 1, 'name' => '湾仔店', 'address' => '湾仔骆克道 88 号地铺', 'status' => 1]
        );

        // ──────────── 商品分类 ────────────
        $catVeg     = ProductCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '蔬菜',   'code' => 'VEG',  'sort_order' => 1]);
        $catFruit   = ProductCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '水果',   'code' => 'FRT',  'sort_order' => 2]);
        $catMeat    = ProductCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '肉类',   'code' => 'MEAT', 'sort_order' => 3]);
        $catSeafood = ProductCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '水产',   'code' => 'SEA',  'sort_order' => 4]);
        $catTofu    = ProductCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '豆制品', 'code' => 'TOFU', 'sort_order' => 5]);
        $catDry     = ProductCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '干货',   'code' => 'DRY',  'sort_order' => 6]);

        // ──────────── 供应商 ────────────
        $supplierA = Supplier::firstOrCreate(
            ['organization_id' => $org->id, 'name' => '新鲜直送农场'],
            ['organization_id' => $org->id, 'code' => 'SUP001', 'contact_name' => '陈老板',
             'contact_phone' => '9123 4567', 'payment_terms' => 2, 'payment_days' => 30,
             'delivery_lead_days' => 1, 'rating' => 5, 'status' => 1, 'notes' => '专供蔬菜水果，每日早上 7 点送货']
        );

        $supplierB = Supplier::firstOrCreate(
            ['organization_id' => $org->id, 'name' => '港鲜肉类批发'],
            ['organization_id' => $org->id, 'code' => 'SUP002', 'contact_name' => '黄先生',
             'contact_phone' => '9876 5432', 'payment_terms' => 1, 'payment_days' => 0,
             'delivery_lead_days' => 1, 'rating' => 4, 'status' => 1, 'notes' => '供应猪肉、鸡肉、牛肉，现款现货']
        );

        $supplierC = Supplier::firstOrCreate(
            ['organization_id' => $org->id, 'name' => '南海水产行'],
            ['organization_id' => $org->id, 'code' => 'SUP003', 'contact_name' => '李姐',
             'contact_phone' => '6688 9900', 'payment_terms' => 2, 'payment_days' => 15,
             'delivery_lead_days' => 1, 'rating' => 4, 'status' => 1, 'notes' => '鱼虾蟹贝类，当日早市配送']
        );

        // ──────────── 商品（含供应商绑定） ────────────
        $productDefs = [
            // 供应商A — 蔬菜
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '胡萝卜',   'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 14, 'purchase_price' => 1.2],
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '西兰花',   'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 5,  'purchase_price' => 3.5],
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '白菜',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 7,  'purchase_price' => 0.8],
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '番茄',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 7,  'purchase_price' => 2.5],
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '青椒',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 7,  'purchase_price' => 2.8],
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '土豆',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 30, 'purchase_price' => 1.0],
            ['supplier_id' => $supplierA->id, 'category_id' => $catVeg->id,     'name' => '洋葱',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 30, 'purchase_price' => 1.5],
            // 供应商A — 水果
            ['supplier_id' => $supplierA->id, 'category_id' => $catFruit->id,   'name' => '苹果',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 14, 'purchase_price' => 4.5],
            ['supplier_id' => $supplierA->id, 'category_id' => $catFruit->id,   'name' => '香蕉',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 5,  'purchase_price' => 3.2],
            ['supplier_id' => $supplierA->id, 'category_id' => $catFruit->id,   'name' => '橙子',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 1, 'shelf_life_days' => 14, 'purchase_price' => 3.8],
            // 供应商A — 豆制品 & 干货
            ['supplier_id' => $supplierA->id, 'category_id' => $catTofu->id,    'name' => '豆腐',     'unit' => '块', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 3,   'purchase_price' => 2.5],
            ['supplier_id' => $supplierA->id, 'category_id' => $catTofu->id,    'name' => '豆芽',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 2,   'purchase_price' => 1.8],
            ['supplier_id' => $supplierA->id, 'category_id' => $catDry->id,     'name' => '大米',     'unit' => '斤', 'is_fresh' => false, 'storage_condition' => 1, 'shelf_life_days' => 365, 'purchase_price' => 2.2],
            ['supplier_id' => $supplierA->id, 'category_id' => $catDry->id,     'name' => '食用油',   'unit' => '桶', 'is_fresh' => false, 'storage_condition' => 1, 'shelf_life_days' => 540, 'purchase_price' => 68.0],
            // 供应商B — 肉类
            ['supplier_id' => $supplierB->id, 'category_id' => $catMeat->id,    'name' => '猪五花肉', 'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 3, 'purchase_price' => 18.0],
            ['supplier_id' => $supplierB->id, 'category_id' => $catMeat->id,    'name' => '鸡胸肉',   'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 3, 'purchase_price' => 12.5],
            ['supplier_id' => $supplierB->id, 'category_id' => $catMeat->id,    'name' => '牛腩',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 3, 'purchase_price' => 55.0],
            ['supplier_id' => $supplierB->id, 'category_id' => $catMeat->id,    'name' => '猪排骨',   'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 3, 'purchase_price' => 22.0],
            // 供应商C — 水产
            ['supplier_id' => $supplierC->id, 'category_id' => $catSeafood->id, 'name' => '鲈鱼',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 1, 'purchase_price' => 28.0],
            ['supplier_id' => $supplierC->id, 'category_id' => $catSeafood->id, 'name' => '基围虾',   'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 1, 'purchase_price' => 65.0],
            ['supplier_id' => $supplierC->id, 'category_id' => $catSeafood->id, 'name' => '花蛤',     'unit' => '斤', 'is_fresh' => true,  'storage_condition' => 2, 'shelf_life_days' => 1, 'purchase_price' => 12.0],
        ];

        $productMap = collect();
        foreach ($productDefs as $def) {
            $price = $def['purchase_price'];
            unset($def['purchase_price']);

            $product = Product::firstOrCreate(
                ['organization_id' => $org->id, 'name' => $def['name']],
                array_merge($def, ['organization_id' => $org->id, 'status' => 1])
            );

            // 更新 supplier_id（兼容已有数据）
            if (! $product->supplier_id) {
                $product->update(['supplier_id' => $def['supplier_id']]);
            }

            // supplier_products 记录（采购价格）
            SupplierProduct::firstOrCreate(
                ['supplier_id' => $def['supplier_id'], 'product_id' => $product->id],
                ['purchase_price' => $price, 'min_order_qty' => 5, 'is_primary' => true, 'delivery_lead_days' => 1]
            );

            $productMap->put($product->name, $product);
        }

        // ──────────── 门店库存 ────────────
        $inventoryData = [
            $storeXiWan->id => [
                '胡萝卜' => [85, 1.2], '西兰花' => [42, 3.5], '白菜' => [120, 0.8], '番茄' => [60, 2.5],
                '青椒' => [38, 2.8], '土豆' => [95, 1.0], '洋葱' => [70, 1.5], '苹果' => [55, 4.5],
                '香蕉' => [40, 3.2], '橙子' => [30, 3.8], '猪五花肉' => [25, 18.0], '鸡胸肉' => [18, 12.5],
                '牛腩' => [10, 55.0], '猪排骨' => [15, 22.0], '鲈鱼' => [12, 28.0], '基围虾' => [8, 65.0],
                '花蛤' => [20, 12.0], '豆腐' => [30, 2.5], '豆芽' => [25, 1.8], '大米' => [200, 2.2], '食用油' => [12, 68.0],
            ],
            $storeWanChai->id => [
                '胡萝卜' => [60, 1.2], '西兰花' => [35, 3.5], '白菜' => [90, 0.8], '番茄' => [45, 2.5],
                '青椒' => [28, 2.8], '土豆' => [5, 1.0], '洋葱' => [50, 1.5], '苹果' => [70, 4.5],
                '香蕉' => [3, 3.2], '橙子' => [55, 3.8], '猪五花肉' => [30, 18.0], '鸡胸肉' => [22, 12.5],
                '牛腩' => [8, 55.0], '猪排骨' => [18, 22.0], '鲈鱼' => [15, 28.0], '基围虾' => [12, 65.0],
                '花蛤' => [25, 12.0], '豆腐' => [40, 2.5], '豆芽' => [18, 1.8], '大米' => [150, 2.2], '食用油' => [8, 68.0],
            ],
        ];

        $now = now();

        foreach ($inventoryData as $storeId => $items) {
            foreach ($items as $productName => [$qty, $cost]) {
                if (! $productMap->has($productName)) {
                    continue;
                }
                $product = $productMap[$productName];

                $inv = Inventory::firstOrCreate(
                    ['store_id' => $storeId, 'product_id' => $product->id],
                    ['current_qty' => $qty, 'available_qty' => $qty, 'locked_qty' => 0,
                     'avg_cost' => $cost, 'last_in_at' => $now->copy()->subHours(rand(2, 48))]
                );

                if ($inv->wasRecentlyCreated) {
                    InventoryTransaction::create([
                        'store_id'         => $storeId,
                        'product_id'       => $product->id,
                        'transaction_type' => 1,
                        'qty_change'       => $qty,
                        'qty_before'       => 0,
                        'qty_after'        => $qty,
                        'unit_cost'        => $cost,
                        'total_cost'       => round($qty * $cost, 2),
                        'reference_type'   => 'seed',
                        'notes'            => '演示初始库存',
                        'operator_id'      => 1,
                        'created_at'       => $now->copy()->subHours(rand(2, 48)),
                    ]);
                }
            }
        }

        // ──────────── 支出分类 ────────────
        $catRaw    = ExpenseCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '原材料采购', 'code' => 'RAW',  'is_cogs' => true,  'sort_order' => 1]);
        $catUtil   = ExpenseCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '水电费',     'code' => 'UTIL', 'is_cogs' => false, 'sort_order' => 2]);
        $catLabor  = ExpenseCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '人工费用',   'code' => 'LAB',  'is_cogs' => false, 'sort_order' => 3]);
        $catSupply = ExpenseCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '耗材物料',   'code' => 'SUP',  'is_cogs' => false, 'sort_order' => 4]);
        $catRent   = ExpenseCategory::firstOrCreate(['organization_id' => $org->id, 'name' => '租金',       'code' => 'RENT', 'is_cogs' => false, 'sort_order' => 5]);

        // ──────────── 支出记录 ────────────
        $expenseData = [
            [$storeXiWan->id,   $catRaw->id,    'EXP-XWH-001',  3850.00, '-7 days', '新鲜直送农场', 1, 2],
            [$storeXiWan->id,   $catRaw->id,    'EXP-XWH-002',  2200.00, '-5 days', '港鲜肉类批发', 1, 2],
            [$storeXiWan->id,   $catUtil->id,   'EXP-XWH-003',   680.00, '-3 days', '中华电力',     3, 2],
            [$storeXiWan->id,   $catSupply->id, 'EXP-XWH-004',   320.50, '-2 days', '包装袋/托盘',  1, 2],
            [$storeXiWan->id,   $catRaw->id,    'EXP-XWH-005',  4100.00, '-1 days', '新鲜直送农场', 2, 1],
            [$storeWanChai->id, $catRaw->id,    'EXP-WCH-001',  4500.00, '-6 days', '新鲜直送农场', 1, 2],
            [$storeWanChai->id, $catRaw->id,    'EXP-WCH-002',  3100.00, '-4 days', '南海水产行',   1, 2],
            [$storeWanChai->id, $catUtil->id,   'EXP-WCH-003',   750.00, '-3 days', '港灯',         3, 2],
            [$storeWanChai->id, $catLabor->id,  'EXP-WCH-004',  8800.00, '-1 days', '3月上半月工资', 2, 1],
            [$storeWanChai->id, $catRent->id,   'EXP-WCH-005', 12000.00, '-1 days', '3月租金',       2, 1],
        ];

        foreach ($expenseData as [$storeId, $catId, $no, $amount, $dateOffset, $vendor, $payMethod, $payStatus]) {
            Expense::firstOrCreate(
                ['expense_no' => $no],
                ['store_id' => $storeId, 'category_id' => $catId, 'amount' => $amount,
                 'expense_date' => now()->modify($dateOffset)->toDateString(), 'vendor_name' => $vendor,
                 'input_method' => 1, 'payment_method' => $payMethod, 'payment_status' => $payStatus, 'created_by' => 1]
            );
        }

        $this->command->info('✅ 演示数据导入完成！');
        $this->command->info('   门店：西湾河店、湾仔店（+已有铜锣湾旗舰店）');
        $this->command->info('   商品：' . $productMap->count() . ' 种（含供应商绑定）');
        $this->command->info('   供应商：3 家');
        $this->command->info('   库存记录：' . Inventory::count() . ' 条（2 门店）');
        $this->command->info('   支出记录：' . count($expenseData) . ' 条');
    }
}
