<?php

namespace Database\Seeders;

use App\Models\MenuTemplate;
use App\Models\QuickAction;
use Illuminate\Database\Seeder;

class MenuTemplateSeeder extends Seeder
{
    /**
     * 为每个行业确保有一条「默认模版」(生效)，并把该行业未归模版的按钮挂进去。
     * 幂等：默认模版已存在则复用；只补挂 menu_template_id 为空的按钮。
     * 须在 QuickActionSeeder 之后运行（按钮先建好，再归集到模版）。
     */
    public function run(): void
    {
        $slugs = QuickAction::query()
            ->whereNotNull('industry')
            ->distinct()
            ->pluck('industry');

        foreach ($slugs as $slug) {
            $template = MenuTemplate::query()->firstOrCreate(
                ['industry' => $slug, 'name' => '默认模版'],
                ['is_active' => true, 'sort_order' => 0],
            );

            // 该行业还没有任何生效模版时，把默认模版设为生效
            $hasActive = MenuTemplate::query()
                ->where('industry', $slug)
                ->where('is_active', true)
                ->exists();
            if (! $hasActive) {
                $template->update(['is_active' => true]);
            }

            // 该行业「未归模版」的按钮挂到默认模版
            QuickAction::query()
                ->where('industry', $slug)
                ->whereNull('menu_template_id')
                ->update(['menu_template_id' => $template->id]);
        }
    }
}
