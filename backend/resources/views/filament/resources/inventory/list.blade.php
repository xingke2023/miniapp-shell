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

        {{ $this->table }}

    </div>
</x-filament-panels::page>
