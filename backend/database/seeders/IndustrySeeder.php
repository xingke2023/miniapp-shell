<?php

namespace Database\Seeders;

use App\Models\Industry;
use Illuminate\Database\Seeder;

class IndustrySeeder extends Seeder
{
    /**
     * 行业模版列表（小程序启动「选择行业」页）。
     * slug 与 quick_actions.industry 对应；fresh 为现有真实模版，其余为菜单外壳。
     */
    public function run(): void
    {
        $rows = [
            ['slug' => 'fresh',        'emoji' => '🥬', 'name' => '生鲜门店',   'title' => '舌尖生鲜',       'description' => '果蔬肉禽 · 进货/库存/损耗/销售', 'sort_order' => 20, 'ai_media' => true],
            ['slug' => 'erp_crm',      'emoji' => '📊', 'name' => '进销存及CRM', 'title' => '进销存及CRM',    'description' => '商品/采购/销售/客户/线索/商机', 'api_base' => 'https://app2.xingke888.com/api', 'sort_order' => 8, 'ai_media' => true],
            ['slug' => 'restaurant',   'emoji' => '🍜', 'name' => '餐饮快餐',   'title' => 'AI 餐饮店长',    'description' => '点餐/营业额/备料/损耗',         'sort_order' => 16],
            ['slug' => 'apparel',      'emoji' => '👕', 'name' => '服装零售',   'title' => 'AI 服装店长',    'description' => '上新/库存/销售/会员',           'sort_order' => 30],
            ['slug' => 'convenience',  'emoji' => '🏪', 'name' => '便利超市',   'title' => 'AI 便利店长',    'description' => '进货/库存/销售/促销',           'sort_order' => 40],
            ['slug' => 'beauty',       'emoji' => '💇', 'name' => '美业服务',   'title' => 'AI 美业管家',    'description' => '预约/会员/消费/员工',           'sort_order' => 50],
            ['slug' => 'manufacturing', 'emoji' => '🏭', 'name' => '制造业',     'title' => 'AI 生产助手',    'description' => '订单/产能/物料/排程',           'sort_order' => 60],
            ['slug' => 'auto_repair',  'emoji' => '🚗', 'name' => '汽修门店',   'title' => 'AI 汽修助手',    'description' => '故障诊断/维修保养/报价工单',     'sort_order' => 65],
            ['slug' => 'insurance',    'emoji' => '🛡️', 'name' => '保险',       'title' => 'AI 保险助手',    'description' => '保单/客户/续保/业绩',           'api_base' => 'https://app3.xingke888.com/api', 'sort_order' => 70, 'ai_media' => true],
            ['slug' => 'finance',      'emoji' => '💰', 'name' => '金融',       'title' => 'AI 金融助手',    'description' => '账户/对账/客户/风控',           'sort_order' => 5],
            ['slug' => 'ecommerce',    'emoji' => '🛒', 'name' => '电商',         'title' => 'AI 电商助手',    'description' => '订单/库存/退款/客服',              'sort_order' => 12],
            ['slug' => 'cross_border', 'emoji' => '🌐', 'name' => '跨境电商',     'title' => 'AI 跨境助手',    'description' => '文案/翻译/五点/侵权检测',           'sort_order' => 92],
        ];

        // 每个行业聊天页登录后的欢迎语（按 slug）。内容贴合该行业菜单能力。
        $greetings = $this->greetings();

        // 幂等：按 slug firstOrCreate，老库也能补插新行业（如 erp_crm）。
        // greeting 单独 update：firstOrCreate 不更新已存在行，且欢迎语会随菜单调整需要覆盖刷新。
        foreach ($rows as $row) {
            $greeting = $greetings[$row['slug']] ?? null;
            $industry = Industry::query()->firstOrCreate(
                ['slug' => $row['slug']],
                $row + ['greeting' => $greeting, 'enabled' => true],
            );
            if ($greeting !== null && $industry->greeting !== $greeting) {
                $industry->update(['greeting' => $greeting]);
            }
        }
    }

    /**
     * 各行业欢迎语：slug => 文案。换行用 \n，小程序按行展示。
     *
     * @return array<string, string>
     */
    private function greetings(): array
    {
        return [
            'fresh' => "我是舌尖生鲜 · AI 店长助手 🥬\n\n直接在下面输入框跟我说，我能帮你：\n📦 查库存 / 报剩余\n💰 录销售 / 查今日销售\n🚚 记进货\n🗑️ 记损耗",
            'erp_crm' => "我是 AI 进销存 & CRM 助手 📊\n\n点下面菜单或直接跟我说，我能帮你：\n📦 商品 / 采购 / 销售\n👥 客户 / 线索 / 商机\n📊 经营数据查询",
            'restaurant' => "我是 AI 餐饮店长 🍜\n\n点下面菜单或直接跟我说，我能帮你：\n📈 营业概况 / 热销菜品\n🥬 备料建议 / 库存\n🗑️ 损耗登记\n👥 会员储值",
            'apparel' => "我是 AI 服装店长 👕\n\n点下面菜单或直接跟我说，我能帮你：\n🆕 上新登记 / 款式管理\n📦 库存 / 尺码缺货\n💰 销售统计\n👥 会员管理",
            'convenience' => "我是 AI 便利店长 🏪\n\n点下面菜单或直接跟我说，我能帮你：\n🚚 进货登记 / 补货建议\n📦 库存 / 临期预警\n💰 销售统计\n🎁 促销活动",
            'beauty' => "我是 AI 美业管家 💇\n\n点下面菜单或直接跟我说，我能帮你：\n📅 预约管理 / 客户回访\n👥 会员 / 办卡储值\n🧾 消费记录\n🏆 员工业绩",
            'manufacturing' => "我是 AI 生产助手 🏭\n\n点下面菜单或直接跟我说，我能帮你：\n📐 工艺文档 · SOP / 参数 / 报价\n🔧 设备运维 · 故障诊断 / 保养\n🔍 质量管理 · 质检 / 8D / 根因\n🛡️ 安全精益 · 隐患排查 / 5S",
            'auto_repair' => "我是 AI 汽修助手 🚗\n\n点下面菜单或直接跟我说，我能帮你：\n🩺 故障诊断 · 故障码 / 异响\n🔧 维修保养 · 方案 / 工时 / 配件\n💵 报价开单 · 报价单 / 工单\n🛎️ 客户服务 · 沟通 / 回访话术",
            'insurance' => "我是 AI 保险助手 🛡️\n\n点下面菜单或直接跟我说，我能帮你：\n📋 产品对比 / 条款解读 / 方案设计\n🚀 展业话术 / 拒绝处理 / 拓客文案\n🛎️ AI客服 / 理赔指引 / 续保提醒\n🎓 新人培训 / 话术演练 / 合规\n📊 业绩查询 / 客户跟进",
            'finance' => "我是 AI 金融助手 💰\n\n点下面菜单或直接跟我说，我能帮你：\n📈 投研分析 · 财报 / 估值 / DCF\n🏦 投行交易 · 建模 / 路演 PPT\n💰 基金行政 · 对账 / NAV / 月末结账\n🌱 私募财富 · 寻源 / 组合分析",
            'ecommerce' => "我是 AI 电商助手 🛒\n\n点下面菜单或直接跟我说，我能帮你：\n✍️ 写标题 / 详情 / 种草文案\n🎬 短视频 / 直播话术\n📈 关键词 / 竞品 / 活动策划\n🛎️ 客服 / 差评 / 售后话术",
            'cross_border' => "我是 AI 跨境助手 🌐\n\n点下面菜单或直接跟我说，我能帮你：\n🤖 AI 工具 · 翻译 / 文案 / 五点描述\n🔍 侵权检测 · 单词 / 品牌专利\n📊 经营查询 / 日常管理",
        ];
    }
}
