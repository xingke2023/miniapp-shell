<?php

namespace App\Filament\Forms\Components;

use Filament\Forms\Components\Field;

class IconPickerField extends Field
{
    protected string $view = 'filament.forms.components.icon-picker';

    /** @return array<int, array{name: string, label: string, category: string}> */
    public function getIcons(): array
    {
        $icons = [
            // 商品
            ['name' => 'shopping-cart',             'label' => '购物车',    'category' => '商品'],
            ['name' => 'cube',                       'label' => '商品方块',  'category' => '商品'],
            ['name' => 'squares-2x2',               'label' => '分类',      'category' => '商品'],
            ['name' => 'tag',                        'label' => '标签',      'category' => '商品'],
            ['name' => 'gift',                       'label' => '礼品',      'category' => '商品'],
            ['name' => 'clipboard-document-list',   'label' => '商品清单',  'category' => '商品'],
            ['name' => 'archive-box',               'label' => '存档箱',    'category' => '商品'],
            ['name' => 'inbox-stack',               'label' => '堆叠',      'category' => '商品'],
            ['name' => 'scale',                     'label' => '秤',        'category' => '商品'],
            ['name' => 'beaker',                    'label' => '烧杯',      'category' => '商品'],
            ['name' => 'fire',                      'label' => '热销',      'category' => '商品'],
            // 销售
            ['name' => 'chart-bar',                 'label' => '柱状图',    'category' => '销售'],
            ['name' => 'chart-pie',                 'label' => '饼图',      'category' => '销售'],
            ['name' => 'banknotes',                 'label' => '现金',      'category' => '销售'],
            ['name' => 'credit-card',               'label' => '银行卡',    'category' => '销售'],
            ['name' => 'receipt-percent',           'label' => '收据',      'category' => '销售'],
            ['name' => 'currency-yen',              'label' => '货币',      'category' => '销售'],
            ['name' => 'presentation-chart-bar',   'label' => '演示图表',  'category' => '销售'],
            ['name' => 'arrow-trending-up',         'label' => '趋势上升',  'category' => '销售'],
            ['name' => 'arrow-trending-down',       'label' => '趋势下降',  'category' => '销售'],
            ['name' => 'document-chart-bar',        'label' => '文档图表',  'category' => '销售'],
            // 库存
            ['name' => 'cube-transparent',          'label' => '透明方块',  'category' => '库存'],
            ['name' => 'clipboard-document-check', 'label' => '核对清单',  'category' => '库存'],
            ['name' => 'truck',                     'label' => '货车进货',  'category' => '库存'],
            ['name' => 'arrow-down-tray',           'label' => '入库',      'category' => '库存'],
            ['name' => 'arrow-up-tray',             'label' => '出库',      'category' => '库存'],
            ['name' => 'arrow-path',                'label' => '盘点刷新',  'category' => '库存'],
            ['name' => 'funnel',                    'label' => '筛选',      'category' => '库存'],
            ['name' => 'table-cells',               'label' => '表格',      'category' => '库存'],
            // 人员
            ['name' => 'user-group',                'label' => '用户群',    'category' => '人员'],
            ['name' => 'users',                     'label' => '多用户',    'category' => '人员'],
            ['name' => 'user',                      'label' => '用户',      'category' => '人员'],
            ['name' => 'identification',            'label' => '身份证',    'category' => '人员'],
            ['name' => 'briefcase',                 'label' => '公文包',    'category' => '人员'],
            ['name' => 'academic-cap',              'label' => '学帽',      'category' => '人员'],
            // 运营
            ['name' => 'calendar-days',             'label' => '日历',      'category' => '运营'],
            ['name' => 'clock',                     'label' => '时钟',      'category' => '运营'],
            ['name' => 'bell',                      'label' => '铃铛',      'category' => '运营'],
            ['name' => 'megaphone',                 'label' => '扩音器',    'category' => '运营'],
            ['name' => 'star',                      'label' => '星标',      'category' => '运营'],
            ['name' => 'heart',                     'label' => '爱心',      'category' => '运营'],
            ['name' => 'hand-thumb-up',             'label' => '点赞',      'category' => '运营'],
            ['name' => 'bolt',                      'label' => '闪电',      'category' => '运营'],
            ['name' => 'sparkles',                  'label' => '闪光',      'category' => '运营'],
            ['name' => 'sun',                       'label' => '太阳',      'category' => '运营'],
            // 系统
            ['name' => 'cog-6-tooth',               'label' => '设置',      'category' => '系统'],
            ['name' => 'wrench-screwdriver',        'label' => '工具',      'category' => '系统'],
            ['name' => 'shield-check',              'label' => '安全',      'category' => '系统'],
            ['name' => 'lock-closed',               'label' => '锁定',      'category' => '系统'],
            ['name' => 'key',                       'label' => '钥匙',      'category' => '系统'],
            ['name' => 'globe-alt',                 'label' => '地球',      'category' => '系统'],
            ['name' => 'building-office',           'label' => '办公楼',    'category' => '系统'],
            ['name' => 'building-storefront',       'label' => '门店',      'category' => '系统'],
            ['name' => 'map-pin',                   'label' => '位置',      'category' => '系统'],
            // 通用
            ['name' => 'home',                      'label' => '主页',      'category' => '通用'],
            ['name' => 'magnifying-glass',          'label' => '搜索',      'category' => '通用'],
            ['name' => 'plus-circle',               'label' => '添加',      'category' => '通用'],
            ['name' => 'pencil-square',             'label' => '编辑',      'category' => '通用'],
            ['name' => 'trash',                     'label' => '删除',      'category' => '通用'],
            ['name' => 'check-circle',              'label' => '确认',      'category' => '通用'],
            ['name' => 'x-circle',                  'label' => '取消',      'category' => '通用'],
            ['name' => 'information-circle',        'label' => '信息',      'category' => '通用'],
            ['name' => 'question-mark-circle',      'label' => '问号',      'category' => '通用'],
            ['name' => 'list-bullet',               'label' => '列表',      'category' => '通用'],
            ['name' => 'bars-3',                    'label' => '菜单',      'category' => '通用'],
            ['name' => 'qr-code',                   'label' => '二维码',    'category' => '通用'],
            ['name' => 'phone',                     'label' => '电话',      'category' => '通用'],
            ['name' => 'chat-bubble-left',          'label' => '聊天',      'category' => '通用'],
            ['name' => 'envelope',                  'label' => '邮件',      'category' => '通用'],
            ['name' => 'paper-airplane',            'label' => '发送',      'category' => '通用'],
            ['name' => 'camera',                    'label' => '相机',      'category' => '通用'],
            ['name' => 'photo',                     'label' => '图片',      'category' => '通用'],
            ['name' => 'microphone',                'label' => '麦克风',    'category' => '通用'],
            ['name' => 'speaker-wave',              'label' => '音量',      'category' => '通用'],
            ['name' => 'document-text',             'label' => '文档',      'category' => '通用'],
            ['name' => 'folder',                    'label' => '文件夹',    'category' => '通用'],
        ];

        return array_map(function (array $icon): array {
            $icon['svg'] = svg('heroicon-o-' . $icon['name'], ['class' => 'w-full h-full'])->toHtml();

            return $icon;
        }, $icons);
    }
}
