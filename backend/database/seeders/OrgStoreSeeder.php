<?php

namespace Database\Seeders;

use App\Models\Organization;
use App\Models\Store;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OrgStoreSeeder extends Seeder
{
    /**
     * 基础租户骨架：组织 / 区域 / 默认门店（MVP 控制器硬编码 store_id=1）。
     */
    public function run(): void
    {
        $org = Organization::firstOrCreate(
            ['code' => 'SJTXG'],
            ['name' => '舌尖香港']
        );

        $regionId = DB::table('regions')->where('organization_id', $org->id)->where('code', 'HK')->value('id');
        if (! $regionId) {
            $regionId = DB::table('regions')->insertGetId([
                'organization_id' => $org->id,
                'name' => '香港',
                'code' => 'HK',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        Store::firstOrCreate(
            ['code' => 'XWH'],
            [
                'organization_id' => $org->id,
                'region_id' => $regionId,
                'name' => '西湾河店',
                'address' => '西湾河筲箕湾道 18 号地铺',
                'status' => 1,
            ]
        );
    }
}
