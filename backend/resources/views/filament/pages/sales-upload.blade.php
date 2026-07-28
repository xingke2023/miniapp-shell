<x-filament-panels::page>

    {{-- 门店 Tabs --}}
    <div class="flex flex-wrap gap-2 pb-3">
        @foreach ($this->getStores() as $store)
            <button
                wire:click="setStore('{{ $store->id }}')"
                class="rounded-lg px-4 py-2 text-sm font-medium shadow-sm ring-1 transition-all duration-150 focus:outline-none
                    {{ $activeStoreId == $store->id
                        ? 'bg-primary-600 text-white ring-primary-500'
                        : 'bg-white text-gray-700 ring-gray-300 hover:bg-gray-50 dark:bg-gray-800 dark:text-gray-300 dark:ring-white/10 dark:hover:bg-gray-700' }}"
            >
                {{ $store->name }}
            </button>
        @endforeach
    </div>

    @if ($activeStoreId)

    {{-- 上传表单 --}}
    <x-filament::section>
        <x-slot name="heading">上传销售明细 Excel</x-slot>
        <x-slot name="description">支持从收银系统导出的 .xlsx / .xls / .csv 文件，AI 将自动识别品名、数量、金额并写入数据库</x-slot>

        <form wire:submit="submitUpload">
            <div class="flex flex-wrap items-end gap-3">

                {{-- 销售日期 --}}
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-gray-700 dark:text-gray-300">销售日期</label>
                    <input
                        type="date"
                        wire:model="saleDate"
                        class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm shadow-sm focus:outline-none
                               dark:border-white/10 dark:bg-white/5 dark:text-white"
                    >
                    @error('saleDate')
                        <p class="text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                {{-- 选择文件 --}}
                <div class="flex flex-col gap-1">
                    <label class="text-sm font-medium text-gray-700 dark:text-gray-300">选择文件</label>
                    <input
                        type="file"
                        wire:model="uploadFile"
                        accept=".xlsx,.xls,.csv"
                        class="block text-sm text-gray-700 file:mr-3 file:rounded-lg file:border-0
                               file:bg-primary-50 file:px-4 file:py-2 file:text-sm file:font-medium
                               file:text-primary-700 hover:file:bg-primary-100
                               dark:text-gray-300 dark:file:bg-primary-900/30 dark:file:text-primary-300"
                    >
                    @error('uploadFile')
                        <p class="text-xs text-red-500">{{ $message }}</p>
                    @enderror
                </div>

                {{-- 提交按钮 --}}
                <button
                    type="submit"
                    wire:loading.attr="disabled"
                    style="padding-left: 2.5rem; padding-right: 2.5rem;"
                    class="inline-flex items-center gap-2 rounded-lg bg-primary-600 py-2 text-sm font-semibold
                           text-white shadow-sm hover:bg-primary-500 disabled:cursor-not-allowed disabled:opacity-60
                           focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                    <span wire:loading wire:target="submitUpload" style="display:none; white-space:nowrap;" class="inline-flex items-center gap-2">
                        <svg class="h-4 w-4 animate-spin" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 0 1 8-8V0C5.373 0 0 5.373 0 12h4z"></path>
                        </svg>
                        AI 解析中，请稍候…
                    </span>
                    <span wire:loading.remove wire:target="submitUpload" class="inline-flex items-center gap-2">
                        <x-heroicon-o-arrow-up-tray class="h-4 w-4" />
                        上传并解析
                    </span>
                </button>

            </div>
        </form>
    </x-filament::section>

    {{-- 历史上传列表 --}}
    <x-filament::section>
        <x-slot name="heading">历史上传记录</x-slot>

        @php $uploads = $this->getUploads(); @endphp

        @if ($uploads->isEmpty())
            <div class="py-10 text-center text-sm text-gray-400 dark:text-gray-500">
                暂无上传记录
            </div>
        @else
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead>
                        <tr class="border-b border-gray-200 text-xs font-semibold uppercase text-gray-500 dark:border-white/10 dark:text-gray-400">
                            <th class="pb-2 pr-4">销售日期</th>
                            <th class="pb-2 pr-4">文件名</th>
                            <th class="pb-2 pr-4">状态</th>
                            <th class="pb-2 pr-4 text-right">处理 / 总计</th>
                            <th class="pb-2 pr-4">AI 摘要</th>
                            <th class="pb-2 pr-4">上传人</th>
                            <th class="pb-2 pr-4">上传时间</th>
                            <th class="pb-2"></th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/5">
                        @foreach ($uploads as $upload)
                            <tr wire:key="upload-{{ $upload->id }}" class="text-gray-700 dark:text-gray-300">
                                <td class="py-2.5 pr-4 font-mono text-xs">{{ $upload->sale_date->format('Y-m-d') }}</td>
                                <td class="py-2.5 pr-4 max-w-xs truncate" title="{{ $upload->original_filename }}">
                                    {{ $upload->original_filename }}
                                </td>
                                <td class="py-2.5 pr-4">
                                    @php
                                        $statusClass = match ($upload->status) {
                                            0 => 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300',
                                            1 => 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300',
                                            2 => 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300',
                                            3 => 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',
                                            default => 'bg-gray-100 text-gray-600',
                                        };
                                    @endphp
                                    <span class="rounded-full px-2 py-0.5 text-xs font-medium {{ $statusClass }}">
                                        {{ $upload->status_label }}
                                    </span>
                                    @if ($upload->error_message)
                                        <p class="mt-0.5 text-xs text-red-500" title="{{ $upload->error_message }}">
                                            {{ Str::limit($upload->error_message, 40) }}
                                        </p>
                                    @endif
                                </td>
                                <td class="py-2.5 pr-4 text-right font-mono text-xs">
                                    <span class="text-green-600 dark:text-green-400">{{ $upload->processed_items }}</span>
                                    @if ($upload->failed_items > 0)
                                        <span class="text-red-500"> / {{ $upload->failed_items }}失败</span>
                                    @endif
                                    / {{ $upload->total_items }}
                                </td>
                                <td class="py-2.5 pr-4 max-w-xs text-xs text-gray-400 dark:text-gray-500">
                                    {{ Str::limit($upload->ai_result['summary'] ?? '—', 60) }}
                                </td>
                                <td class="py-2.5 pr-4 text-xs">{{ $upload->uploader?->name ?? '—' }}</td>
                                <td class="py-2.5 pr-4 font-mono text-xs text-gray-400">
                                    {{ $upload->created_at->format('m-d H:i') }}
                                </td>
                                <td class="py-2.5">
                                    <button
                                        wire:click="deleteUpload({{ $upload->id }})"
                                        wire:confirm="确定删除该上传记录？"
                                        class="text-xs text-red-400 hover:text-red-600 dark:hover:text-red-300"
                                    >
                                        删除
                                    </button>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            {{-- 分页 --}}
            <div class="mt-4">
                {{ $uploads->links() }}
            </div>
        @endif
    </x-filament::section>

    @else
        <x-filament::section>
            <div class="py-10 text-center text-sm text-gray-400 dark:text-gray-500">
                请先选择门店
            </div>
        </x-filament::section>
    @endif

</x-filament-panels::page>
