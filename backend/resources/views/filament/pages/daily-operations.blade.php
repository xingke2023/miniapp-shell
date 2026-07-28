<x-filament-panels::page>

    {{-- 日期选择 + 门店筛选 --}}
    <div x-data="{ open: false }" x-on:date-selected.window="open = false">

        {{-- 顶栏：折叠按钮 + 门店 checkbox --}}
        <div class="flex items-center gap-4 flex-wrap">
            <button
                x-on:click="open = !open"
                class="flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 transition dark:border-white/10 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10"
            >
                <x-heroicon-m-calendar-days class="w-4 h-4 text-gray-400" />
                <span>选择日期</span>
                <span class="font-semibold text-primary-600 dark:text-primary-400">{{ $date }}</span>
                <x-heroicon-m-chevron-down class="w-3.5 h-3.5 text-gray-400 transition-transform" x-bind:class="open && 'rotate-180'" />
            </button>

            @foreach ($this->getStoreOptions() as $id => $name)
                <label class="flex items-center gap-1.5 cursor-pointer">
                    <input type="checkbox"
                        wire:model.live="selectedStoreIds"
                        value="{{ $id }}"
                        class="rounded border-gray-300 text-primary-600 shadow-sm focus:ring-primary-500 dark:border-white/20 dark:bg-white/5">
                    <span class="text-sm text-gray-700 dark:text-gray-300">{{ $name }}</span>
                </label>
            @endforeach
        </div>

        {{-- 日历面板 --}}
        <div x-show="open" x-transition x-cloak class="mt-2 w-64">
            <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-md dark:border-white/10 dark:bg-gray-900">
                {{-- 月份标题 + 翻页 --}}
                <div class="flex items-center justify-between mb-3">
                    <button wire:click="prevMonth"
                        class="rounded-lg p-1.5 text-gray-500 hover:bg-gray-100 dark:hover:bg-white/10 transition">
                        <x-heroicon-m-chevron-left class="w-4 h-4" />
                    </button>
                    <span class="text-sm font-semibold text-gray-800 dark:text-gray-100">
                        {{ $calendarYear }} 年 {{ $calendarMonth }} 月
                    </span>
                    <button wire:click="nextMonth"
                        class="rounded-lg p-1.5 text-gray-500 hover:bg-gray-100 dark:hover:bg-white/10 transition">
                        <x-heroicon-m-chevron-right class="w-4 h-4" />
                    </button>
                </div>

                {{-- 星期表头 --}}
                <div class="grid grid-cols-7 mb-1">
                    @foreach (['一','二','三','四','五','六','日'] as $dow)
                        <div class="text-center text-xs font-medium text-gray-400 dark:text-gray-500 py-0.5">{{ $dow }}</div>
                    @endforeach
                </div>

                {{-- 日期格 --}}
                <div class="grid grid-cols-7 gap-y-0.5">
                    @foreach ($this->getCalendarDays() as $day)
                        <button
                            wire:click="selectDate('{{ $day['date'] }}')"
                            @class([
                                'flex items-center justify-center rounded-md text-sm h-7 w-full transition-colors focus:outline-none',
                                'bg-primary-600 text-white font-semibold shadow'
                                    => $day['isSelected'],
                                'ring-2 ring-primary-400 text-primary-700 dark:text-primary-300 font-semibold'
                                    => $day['isToday'] && !$day['isSelected'],
                                'text-gray-800 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-white/10'
                                    => $day['inMonth'] && !$day['isSelected'] && !$day['isToday'],
                                'text-gray-300 dark:text-gray-600 hover:bg-gray-50 dark:hover:bg-white/5'
                                    => !$day['inMonth'],
                            ])
                        >
                            {{ $day['day'] }}
                        </button>
                    @endforeach
                </div>
            </div>
        </div>

    </div>

    @php
        $data   = $this->getData();
        $active = $this->activeFilter;

        $cards = [
            'opening'   => ['label' => '昨日收档'],
            'received'  => ['label' => '今日到货'],
            'available' => ['label' => '开档库存'],
            'sold'      => ['label' => '今日销售'],
            'logs'      => ['label' => '操作日志'],
        ];
    @endphp

    {{-- 按钮栏 --}}
    <div class="flex flex-wrap gap-3">
        @foreach ($cards as $key => $card)
            <button
                wire:click="setFilter('{{ $key }}')"
                class="rounded-lg px-4 py-2 text-sm font-medium shadow-sm ring-1 transition-all duration-150 focus:outline-none
                    {{ $active === $key
                        ? 'bg-primary-600 text-white ring-primary-500'
                        : 'bg-white text-gray-700 ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-gray-300 dark:ring-white/10 dark:hover:bg-gray-700' }}"
            >
                {{ $card['label'] }}
            </button>
            @if ($key === 'sold')
                <a href="{{ \App\Filament\Resources\SalesOrderResource::getUrl('index') }}"
                    class="rounded-lg px-4 py-2 text-sm font-medium shadow-sm ring-1 transition-all duration-150 focus:outline-none
                        bg-white text-gray-700 ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-gray-300 dark:ring-white/10 dark:hover:bg-gray-700">
                    销售流水
                </a>
            @endif
        @endforeach
    </div>

    {{-- 操作日志 --}}
    @if ($active === 'logs')
        @php $logs = $this->getLogs(); @endphp
        <x-filament::section>
            <x-slot name="heading">操作日志</x-slot>
            <x-slot name="description">所有远程指令留档——含 AI 助手、手动补正、后台收货</x-slot>

            @if (count($logs) === 0)
                <p class="py-6 text-center text-sm text-gray-400">当日暂无操作记录</p>
            @else
                <div class="-mx-6 -mb-6">
                    <ul class="divide-y divide-gray-100 dark:divide-white/5">
                        @foreach ($logs as $log)
                            <li class="flex items-start gap-3 px-6 py-3 hover:bg-gray-50 dark:hover:bg-white/5">
                                <span class="w-10 shrink-0 pt-0.5 font-mono text-xs text-gray-400">{{ $log['time'] }}</span>
                                <x-filament::badge :color="$log['source_id'] === 1 ? 'primary' : ($log['source_id'] === 2 ? 'info' : 'gray')" size="sm">
                                    {{ $log['source'] }}
                                </x-filament::badge>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm text-gray-800 dark:text-gray-200 break-words">{{ $log['content'] }}</p>
                                    @if ($log['product_name'] || $log['qty_change'] !== null || $log['store_name'])
                                        <p class="mt-0.5 text-xs text-gray-400">
                                            @if ($log['store_name']){{ $log['store_name'] }}@endif
                                            @if ($log['product_name']) · {{ $log['product_name'] }}@endif
                                            @if ($log['qty_change'] !== null) · {{ $log['qty_change'] > 0 ? '+' : '' }}{{ $log['qty_change'] }}@endif
                                        </p>
                                    @endif
                                </div>
                                <x-filament::badge :color="$log['is_operational'] ? 'success' : 'gray'" size="sm">
                                    {{ $log['is_operational'] ? '已执行' : '仅记录' }}
                                </x-filament::badge>
                            </li>
                        @endforeach
                    </ul>
                </div>
            @endif
        </x-filament::section>

    {{-- 商品明细（其余五个按钮） --}}
    @elseif ($active !== '')
        @php
            $card  = $cards[$active];
            $items = match ($active) {
                'opening'   => $data['products']->where('opening_qty', '>', 0)->sortByDesc('opening_qty')->values(),
                'received'  => $data['products']->where('received_qty', '>', 0)->sortByDesc('received_qty')->values(),
                'available' => $data['products']->sortByDesc('available_qty')->values(),
                'sold'      => $data['products']->where('sold_qty', '>', 0)->filter(function ($row) {
                                    if (!$this->filterSoldOut && !$this->filterLowStock) return true;
                                    $matchSoldOut  = $this->filterSoldOut  && $row['is_sold_out'];
                                    $matchLowStock = $this->filterLowStock && !$row['is_sold_out'] && $row['closing_qty'] > 0 && $row['closing_qty'] <= 10;
                                    return $matchSoldOut || $matchLowStock;
                                })->sortByDesc('sold_amount')->values(),
                default     => collect(),
            };
        @endphp

        <x-filament::section>
            <x-slot name="heading">
                <div class="flex items-center gap-4">
                    <span>{{ $card['label'] }} · 商品明细</span>
                    @if ($active === 'sold')
                        <label class="flex items-center gap-1.5 cursor-pointer text-sm font-normal text-gray-600 dark:text-gray-400">
                            <input type="checkbox" wire:model.live="filterSoldOut"
                                class="rounded border-gray-300 text-red-600 shadow-sm focus:ring-red-500 dark:border-white/20 dark:bg-white/5">
                            已售罄
                        </label>
                        <label class="flex items-center gap-1.5 cursor-pointer text-sm font-normal text-gray-600 dark:text-gray-400">
                            <input type="checkbox" wire:model.live="filterLowStock"
                                class="rounded border-gray-300 text-amber-500 shadow-sm focus:ring-amber-500 dark:border-white/20 dark:bg-white/5">
                            库存低
                        </label>
                    @endif
                </div>
            </x-slot>
            <x-slot name="description">{{ $data['date'] }}</x-slot>

            @if ($items->isEmpty())
                <p class="py-6 text-center text-sm text-gray-400">暂无数据</p>
            @else
                <div class="-mx-6 -mb-6 overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="border-b border-gray-200 bg-gray-50 dark:border-white/10 dark:bg-white/5">
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400">商品</th>
                                @if ($active === 'opening')
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">昨日收档</th>
                                @elseif ($active === 'received')
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">今日进货</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">昨日收档</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">当前库存</th>
                                @elseif ($active === 'available')
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">开盘库存</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">昨日</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">进货</th>
                                    <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-400">状态</th>
                                @elseif ($active === 'sold')
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">销售金额</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">已售数量</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">到货</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">笔数</th>
                                    <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-400">售罄时间</th>
                                    <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-400">当前库存</th>
                                    <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-400">状态</th>
                                @endif
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-white/5">
                            @foreach ($items as $row)
                                <tr class="hover:bg-gray-50 dark:hover:bg-white/5">
                                    <td class="px-6 py-3">
                                        <span class="font-medium text-gray-950 dark:text-white">{{ $row['product_name'] }}</span>
                                        <span class="ml-1.5 text-xs text-gray-400">{{ $row['unit'] }}</span>
                                    </td>
                                    @if ($active === 'opening')
                                        <td class="px-6 py-3 text-right tabular-nums font-semibold text-gray-800 dark:text-gray-200">{{ $row['opening_qty'] + 0 }}</td>
                                    @elseif ($active === 'received')
                                        <td class="px-6 py-3 text-right tabular-nums font-semibold text-blue-600 dark:text-blue-400">+{{ $row['received_qty'] + 0 }}</td>
                                        <td class="px-6 py-3 text-right tabular-nums text-gray-500">{{ $row['opening_qty'] + 0 }}</td>
                                        <td class="px-6 py-3 text-right tabular-nums font-medium text-gray-800 dark:text-gray-200">{{ $row['closing_qty'] + 0 }}</td>
                                    @elseif ($active === 'available')
                                        <td class="px-6 py-3 text-right tabular-nums font-semibold text-primary-600 dark:text-primary-400">{{ $row['available_qty'] + 0 }}</td>
                                        <td class="px-6 py-3 text-right tabular-nums text-gray-500">{{ $row['opening_qty'] + 0 }}</td>
                                        <td class="px-6 py-3 text-right tabular-nums text-gray-500">
                                            @if ($row['received_qty'] > 0)
                                                <span class="text-blue-500">+{{ $row['received_qty'] + 0 }}</span>
                                            @else —
                                            @endif
                                        </td>
                                        <td class="px-6 py-3 text-center">
                                            @if ($row['is_sold_out'])
                                                <x-filament::badge color="danger" size="sm">售罄</x-filament::badge>
                                            @elseif ($row['closing_qty'] <= 5)
                                                <x-filament::badge color="warning" size="sm">低库存</x-filament::badge>
                                            @else
                                                <x-filament::badge color="success" size="sm">正常</x-filament::badge>
                                            @endif
                                        </td>
                                    @elseif ($active === 'sold')
                                        <td class="px-6 py-3 text-right tabular-nums font-semibold text-green-600 dark:text-green-400">
                                            @if ($row['sold_amount'] > 0) ¥{{ number_format($row['sold_amount'], 2) }} @else — @endif
                                        </td>
                                        <td class="px-6 py-3 text-right tabular-nums text-gray-600 dark:text-gray-400">{{ $row['sold_qty'] + 0 }}</td>
                                        <td class="px-6 py-3 text-right tabular-nums text-gray-500">
                                            @if ($row['received_qty'] > 0)
                                                <span class="text-blue-500">+{{ $row['received_qty'] + 0 }}</span>
                                            @else —
                                            @endif
                                        </td>
                                        <td class="px-6 py-3 text-right tabular-nums text-gray-400">{{ $row['transaction_count'] }}</td>
                                        <td class="px-6 py-3 text-center text-xs text-gray-500">{{ $row['last_sold_at'] ?? '—' }}</td>
                                        <td class="px-6 py-3 text-right tabular-nums font-semibold {{ $row['is_sold_out'] ? 'text-red-500 dark:text-red-400' : 'text-gray-800 dark:text-gray-200' }}">{{ $row['closing_qty'] + 0 }}</td>
                                        <td class="px-6 py-3 text-center">
                                            @if ($row['is_sold_out'])
                                                <x-filament::badge color="danger" size="sm">售罄</x-filament::badge>
                                            @elseif ($row['closing_qty'] > 0 && $row['closing_qty'] <= 10)
                                                <x-filament::badge color="warning" size="sm">库存低</x-filament::badge>
                                            @endif
                                        </td>
                                    @endif
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif

        </x-filament::section>

    @endif

</x-filament-panels::page>
