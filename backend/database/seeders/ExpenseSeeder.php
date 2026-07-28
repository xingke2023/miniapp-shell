<?php

namespace Database\Seeders;

use App\Models\Expense;
use App\Models\ExpenseCategory;
use App\Models\Store;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class ExpenseSeeder extends Seeder
{
    public function run(): void
    {
        $stores = Store::query()->where('status', 1)->get();

        if ($stores->isEmpty()) {
            $this->command->warn('请先运行 DemoDataSeeder 生成门店数据。');

            return;
        }

        $cats = ExpenseCategory::query()->pluck('id', 'name');

        if ($cats->isEmpty()) {
            $this->command->warn('请先运行 DemoDataSeeder 生成支出分类。');

            return;
        }

        $catRaw = $cats->get('原材料采购');
        $catUtil = $cats->get('水电费');
        $catLabor = $cats->get('人工费用');
        $catSupply = $cats->get('耗材物料');
        $catRent = $cats->get('租金');

        /**
         * 每日固定支出模板（每家门店每天都会有这几笔）：
         * [分类ID, 金额范围min, 金额范围max, 支付方式, 商家/描述]
         */
        $dailyTemplates = [
            [$catRaw,    3200, 5500, 2, '新鲜直送农场',  '蔬果采购'],
            [$catRaw,    1800, 3200, 2, '港鲜肉类批发',  '肉类采购'],
            [$catRaw,     800, 1800, 1, '南海水产行',    '水产采购'],
            [$catSupply,  150,  400, 3, '包装耗材',      '包装袋、托盘、保鲜膜'],
        ];

        /**
         * 轮换支出（每天出现 1–2 笔，按天取模选取）：
         */
        $rotatingTemplates = [
            [$catUtil,  600,  900, 5, '中华电力/港灯', '电费'],
            [$catUtil,   80,  150, 1, '水务署',        '水费'],
            [$catLabor, 800, 1200, 2, '员工工资',      '日结人工'],
            [$catRent,  null, null, 2, '房东',         '月租（月初一次性）'],
            [$catSupply, 200, 500, 3, '清洁用品',      '消毒液、清洁工具'],
            [$catLabor, 300,  600, 1, '临时帮工',      '兼职人工'],
            [$catUtil,  100,  200, 5, '宽带/电话',     '通讯费'],
        ];

        $created = 0;

        for ($daysAgo = 4; $daysAgo >= 0; $daysAgo--) {
            $date = now()->subDays($daysAgo)->toDateString();
            $paymentStatus = $daysAgo > 0 ? 2 : 1; // 今天待支付，其余已支付
            $seq = 0;

            foreach ($stores as $store) {
                $storeCode = match ($store->name) {
                    '西湾河店' => 'XWH',
                    '湾仔店' => 'WCH',
                    default => strtoupper(substr(md5($store->name), 0, 3)),
                };

                $dayItems = $dailyTemplates;

                // 每天额外加 1–2 条轮换支出（月初加租金）
                $rotIdx = $daysAgo % count($rotatingTemplates);
                $dayItems[] = $rotatingTemplates[$rotIdx];

                // 月初第一天额外加一笔租金
                if (now()->subDays($daysAgo)->day <= 3) {
                    $dayItems[] = [$catRent, null, null, 2, '房东', '月租'];
                }

                foreach ($dayItems as [$catId, $min, $max, $payMethod, $vendor, $desc]) {
                    if (! $catId) {
                        continue;
                    }

                    // 租金固定金额，按门店区分
                    if ($catId === $catRent) {
                        $amount = match ($store->name) {
                            '西湾河店' => 18000.00,
                            '湾仔店' => 28000.00,
                            default => 15000.00,
                        };
                    } else {
                        $amount = round(rand($min * 100, $max * 100) / 100, 2);
                    }

                    $dateShort = str_replace('-', '', $date);
                    $seq++;
                    $expenseNo = "EXP-{$storeCode}-{$dateShort}-".str_pad($seq, 2, '0', STR_PAD_LEFT);

                    $exists = Expense::query()->where('expense_no', $expenseNo)->exists();
                    if ($exists) {
                        continue;
                    }

                    Expense::create([
                        'store_id' => $store->id,
                        'category_id' => $catId,
                        'expense_no' => $expenseNo,
                        'amount' => $amount,
                        'expense_date' => $date,
                        'vendor_name' => $vendor,
                        'description' => $desc,
                        'input_method' => 1,
                        'payment_method' => $payMethod,
                        'payment_status' => $paymentStatus,
                        'created_by' => 1,
                        'created_at' => Carbon::parse($date)->setTime(rand(8, 20), rand(0, 59)),
                    ]);

                    $created++;
                }
            }
        }

        $this->command->info("✅ 支出演示数据：共创建 {$created} 条（5 天 × {$stores->count()} 门店）");
    }
}
