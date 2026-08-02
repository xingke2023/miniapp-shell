<x-dynamic-component :component="$getFieldWrapperView()" :field="$field">
    @php
        $icons = $getIcons();
        $statePath = $getStatePath();
    @endphp

    <div
        x-data="{
            selected: $wire.$entangle('{{ $statePath }}').live,
            open: false,
            search: '',
            icons: {{ \Illuminate\Support\Js::from($icons) }},
            get filtered() {
                var q = this.search.toLowerCase().trim();
                if (!q) { return this.icons; }
                return this.icons.filter(function(i) {
                    return i.name.indexOf(q) !== -1 || i.label.indexOf(q) !== -1;
                });
            },
            select: function(name) {
                this.selected = name;
                this.open = false;
                this.search = '';
            },
            getIconEntry: function(name) {
                return this.icons.find(function(i) { return i.name === name; }) || null;
            }
        }"
        class="space-y-2"
    >
        {{-- Current selection row --}}
        <div class="flex items-center gap-1.5">
            <div class="flex items-center gap-1.5 flex-1 rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 px-2 py-1.5 min-h-[2rem]">
                <template x-if="selected && getIconEntry(selected)">
                    <div class="flex items-center gap-1.5 min-w-0">
                        <span
                            class="w-4 h-4 text-primary-600 dark:text-primary-400 shrink-0"
                            x-html="getIconEntry(selected).svg"
                        ></span>
                        <span class="text-xs text-gray-700 dark:text-gray-200 truncate" x-text="getIconEntry(selected).label"></span>
                    </div>
                </template>
                <template x-if="!selected || !getIconEntry(selected)">
                    <span class="text-xs text-gray-400">未选择图标</span>
                </template>
            </div>

            <button
                type="button"
                @click="open = !open"
                class="shrink-0 rounded-md border border-primary-300 dark:border-primary-700 bg-primary-50 dark:bg-primary-900/30 px-2 py-1.5 text-xs text-primary-700 dark:text-primary-300 hover:bg-primary-100 dark:hover:bg-primary-900/50 transition-colors"
            >
                <span x-text="open ? '收起' : '选择'"></span>
            </button>

            <template x-if="selected">
                <button
                    type="button"
                    @click="select('')"
                    class="shrink-0 rounded-md border border-gray-200 dark:border-gray-700 p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                    title="清除"
                >
                    <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                    </svg>
                </button>
            </template>
        </div>

        {{-- Picker panel --}}
        <div
            x-show="open"
            x-transition:enter="transition ease-out duration-150"
            x-transition:enter-start="opacity-0 -translate-y-1"
            x-transition:enter-end="opacity-100 translate-y-0"
            x-transition:leave="transition ease-in duration-100"
            x-transition:leave-start="opacity-100 translate-y-0"
            x-transition:leave-end="opacity-0 -translate-y-1"
            class="rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 p-2 space-y-2 shadow-sm"
        >
            {{-- Search --}}
            <input
                type="text"
                x-model="search"
                placeholder="搜索图标..."
                class="w-full rounded-md border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-800 px-2 py-1 text-xs text-gray-800 dark:text-gray-200 placeholder-gray-400 focus:outline-none focus:ring-1 focus:ring-primary-500 focus:border-transparent"
            />

            {{-- Icon grid --}}
            <div class="grid gap-0.5 max-h-48 overflow-y-auto" style="grid-template-columns: repeat(auto-fill, minmax(28px, 1fr))">
                <template x-for="icon in filtered" :key="icon.name">
                    <button
                        type="button"
                        @click="select(icon.name)"
                        :title="icon.label + ' · ' + icon.name"
                        :class="{
                            'ring-1 ring-primary-500 bg-primary-50 dark:bg-primary-900/40 text-primary-600 dark:text-primary-400': selected === icon.name,
                            'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-700 dark:hover:text-gray-200': selected !== icon.name
                        }"
                        class="flex items-center justify-center rounded p-1.5 transition-all"
                    >
                        <span class="w-4 h-4" x-html="icon.svg"></span>
                    </button>
                </template>

                <template x-if="filtered.length === 0">
                    <div class="col-span-12 py-4 text-center text-xs text-gray-400">
                        无匹配图标
                    </div>
                </template>
            </div>

            {{-- Count --}}
            <div class="text-right text-xs text-gray-400">
                <span x-text="filtered.length"></span> / {{ count($icons) }}
            </div>
        </div>
    </div>
</x-dynamic-component>
