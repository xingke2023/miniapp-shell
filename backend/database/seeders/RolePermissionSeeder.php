<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Seeder;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        // ──────────── 完整权限码表 ────────────
        $permDefs = [
            // 工作台
            ['dashboard', 'dashboard.view', '查看工作台', 1],

            // 库存管理
            ['inventory', 'inventory.view',   '查看库存',     2],
            ['inventory', 'inventory.edit',   '手动修改库存', 2],
            ['inventory', 'inventory.adjust', '盘点调整',     2],

            // 进货管理
            ['purchase', 'purchase.view',    '查看进货单',   2],
            ['purchase', 'purchase.create',  '新建进货单',   2],
            ['purchase', 'purchase.edit',    '编辑进货单',   2],
            ['purchase', 'purchase.receive', '确认收货',     2],
            ['purchase', 'purchase.delete',  '删除进货单',   2],

            // 商品管理
            ['products', 'products.view',   '查看商品',   2],
            ['products', 'products.create', '新增商品',   2],
            ['products', 'products.edit',   '编辑商品',   2],
            ['products', 'products.delete', '删除商品',   2],

            // 供应商
            ['suppliers', 'suppliers.view',   '查看供应商',   2],
            ['suppliers', 'suppliers.create', '新增供应商',   2],
            ['suppliers', 'suppliers.edit',   '编辑供应商',   2],
            ['suppliers', 'suppliers.delete', '删除供应商',   2],

            // 财务支出
            ['expenses', 'expenses.view',           '查看支出记录',   2],
            ['expenses', 'expenses.create',         '新建支出记录',   2],
            ['expenses', 'expenses.edit',           '编辑支出记录',   2],
            ['expenses', 'expenses.delete',         '删除支出记录',   2],
            ['expenses', 'expenses.upload_receipt', '上传支付凭证',   2],
            ['expenses', 'expenses.export',         '导出财务数据',   2],

            // 人才库
            ['resumes', 'resumes.view',   '查看简历库', 2],
            ['resumes', 'resumes.create', '新增简历',   2],
            ['resumes', 'resumes.edit',   '编辑简历',   2],
            ['resumes', 'resumes.delete', '删除简历',   2],
            ['resumes', 'resumes.upload', '批量上传简历', 2],

            // AI 助手
            ['ai_assistant', 'ai_assistant.use',    '使用 AI 助手', 2],
            ['ai_assistant', 'ai_assistant.report', '实况上报',     2],

            // 报表分析
            ['reports', 'reports.view',   '查看报表',   1],
            ['reports', 'reports.export', '导出报表',   2],

            // 竞品情报
            ['competitor', 'competitor.view',   '查看竞品数据',   2],
            ['competitor', 'competitor.upload', '上传竞品情报',   2],
            ['competitor', 'competitor.edit',   '维护竞品数据',   2],

            // 用户管理
            ['users', 'users.view',   '查看用户', 2],
            ['users', 'users.create', '新增用户', 2],
            ['users', 'users.edit',   '编辑用户', 2],
            ['users', 'users.delete', '删除用户', 2],

            // 角色权限
            ['roles', 'roles.view',   '查看角色', 2],
            ['roles', 'roles.create', '新建角色', 2],
            ['roles', 'roles.edit',   '编辑角色', 2],
            ['roles', 'roles.delete', '删除角色', 2],
        ];

        $permMap = [];
        foreach ($permDefs as [$module, $code, $name, $type]) {
            $perm = Permission::firstOrCreate(
                ['code' => $code],
                ['module' => $module, 'name' => $name, 'type' => $type]
            );
            $permMap[$code] = $perm->id;
        }

        // ──────────── 4 个核心角色权限矩阵 ────────────
        $matrix = [

            'SUPER_ADMIN' => [
                'name' => '总部总负责人',
                'scope' => 1,
                'description' => '全系统最高权限，全数据查看、规则配置、审批管理',
                'permissions' => array_keys($permMap), // 所有权限
            ],

            'REGION_BUYER' => [
                'name' => '区域采购',
                'scope' => 2,
                'description' => '商品库、供应商、进货管理、结算核对、竞品数据维护',
                'permissions' => [
                    'dashboard.view',
                    'inventory.view',
                    'purchase.view', 'purchase.create', 'purchase.edit', 'purchase.receive', 'purchase.delete',
                    'products.view', 'products.create', 'products.edit', 'products.delete',
                    'suppliers.view', 'suppliers.create', 'suppliers.edit', 'suppliers.delete',
                    'expenses.view', 'expenses.export',
                    'competitor.view', 'competitor.upload', 'competitor.edit',
                    'reports.view', 'reports.export',
                ],
            ],

            'STORE_MANAGER' => [
                'name' => '门店店长',
                'scope' => 3,
                'description' => '本店经营全流程操作、数据查看、调整权限、上传简历、上传支付凭证、上传竞品情报',
                'permissions' => [
                    'dashboard.view',
                    'inventory.view', 'inventory.edit', 'inventory.adjust',
                    'purchase.view', 'purchase.create', 'purchase.edit', 'purchase.receive',
                    'products.view',
                    'suppliers.view',
                    'expenses.view', 'expenses.create', 'expenses.edit', 'expenses.upload_receipt',
                    'resumes.view', 'resumes.create', 'resumes.edit', 'resumes.upload',
                    'ai_assistant.use', 'ai_assistant.report',
                    'competitor.view', 'competitor.upload',
                    'reports.view',
                ],
            ],

            'STORE_STAFF' => [
                'name' => '门店店员',
                'scope' => 3,
                'description' => '仅实况上报、票据上传权限，无核心调整权限',
                'permissions' => [
                    'ai_assistant.use',
                    'ai_assistant.report',
                    'expenses.upload_receipt',
                ],
            ],
        ];

        foreach ($matrix as $code => $def) {
            $role = Role::firstOrCreate(
                ['code' => $code],
                [
                    'name' => $def['name'],
                    'scope' => $def['scope'],
                    'description' => $def['description'],
                ]
            );

            // 更新名称/描述（兼容重复运行）
            $role->update([
                'name' => $def['name'],
                'description' => $def['description'],
                'scope' => $def['scope'],
            ]);

            $permIds = array_filter(
                array_map(fn ($permCode) => $permMap[$permCode] ?? null, $def['permissions'])
            );

            $role->permissions()->sync($permIds);
        }

        $roleCount = Role::count();
        $permCount = Permission::count();
        $this->command->info("✅ 权限矩阵写入完成：{$permCount} 个权限码，{$roleCount} 个角色");
        $this->command->table(
            ['角色代码', '角色名称', '范围', '权限数'],
            Role::with('permissions')->get()->map(fn ($r) => [
                $r->code,
                $r->name,
                match ($r->scope) {
                    1 => '总部', 2 => '区域', 3 => '门店', default => '—'
                },
                $r->permissions->count(),
            ])->toArray()
        );
    }
}
