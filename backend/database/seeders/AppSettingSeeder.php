<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use Illuminate\Database\Seeder;

class AppSettingSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            ['key' => 'miniprogram_title', 'value' => '舌尖生鲜', 'label' => '小程序顶部标题', 'sort_order' => 10],
            ['key' => 'industry_page_title', 'value' => '企业AI落地行业应用案例', 'label' => '行业选择页大标题', 'sort_order' => 20],
            ['key' => 'industry_page_subtitle', 'value' => '请选择你的行业', 'label' => '行业选择页小标题', 'sort_order' => 30],
        ];

        foreach ($defaults as $row) {
            AppSetting::firstOrCreate(['key' => $row['key']], $row);
        }
    }
}
