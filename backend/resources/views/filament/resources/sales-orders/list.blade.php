<x-filament-panels::page @class(['fi-resource-list-records-page'])>
    <div class="flex flex-col gap-y-6">

        <x-filament::section>
            <div class="flex flex-wrap items-center gap-4">
                <div class="flex items-center gap-2">
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">日期</span>
                    <input type="date" wire:model.live="date"
                        class="rounded-lg border border-gray-300 bg-white px-3 py-1.5 text-sm shadow-sm focus:outline-none
                               dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">门店</span>
                    <select wire:model.live="storeId"
                        class="rounded-lg border border-gray-300 bg-white px-3 py-1.5 text-sm shadow-sm focus:outline-none
                               dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <option value="">全部门店</option>
                        @foreach ($this->storeOptions as $id => $name)
                            <option value="{{ $id }}">{{ $name }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </x-filament::section>

        {{-- 导航按钮栏 --}}
        @php
            $baseUrl = \App\Filament\Pages\DailyOperations::getUrl();
            $navButtons = [
                'opening'   => '昨日库存',
                'received'  => '当天进货单',
                'available' => '当天开盘库存',
                'sold'      => '当天销售情况',
            ];
            $btnBase = 'rounded-lg px-4 py-2 text-sm font-medium shadow-sm ring-1 transition-all duration-150 focus:outline-none';
            $btnActive = 'bg-primary-600 text-white ring-primary-500';
            $btnInactive = 'bg-white text-gray-700 ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-gray-300 dark:ring-white/10 dark:hover:bg-gray-700';
        @endphp
        <div class="flex flex-wrap gap-3">
            @foreach ($navButtons as $key => $label)
                <a href="{{ $baseUrl }}?activeFilter={{ $key }}"
                    class="{{ $btnBase }} {{ $btnInactive }}">
                    {{ $label }}
                </a>
            @endforeach
            <span class="{{ $btnBase }} {{ $btnActive }}">零售流水</span>
            <a href="{{ $baseUrl }}?activeFilter=logs"
                class="{{ $btnBase }} {{ $btnInactive }}">
                当天操作日志
            </a>
        </div>

        {{ $this->table }}

    </div>
</x-filament-panels::page>
