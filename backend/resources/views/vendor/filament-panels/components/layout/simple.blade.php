@php
    use Filament\Support\Enums\Width;

    $livewire ??= null;
    $renderHookScopes = $livewire?->getRenderHookScopes();
@endphp

<x-filament-panels::layout.base :livewire="$livewire">
    <div class="ai-login-page">
        {{ \Filament\Support\Facades\FilamentView::renderHook(\Filament\View\PanelsRenderHook::SIMPLE_LAYOUT_START, scopes: $renderHookScopes) }}

        {{-- 左侧 Hero --}}
        <section class="ai-hero">
            <div class="ai-hero-inner">
                <div class="ai-brand-mark">
                    <svg viewBox="0 0 38 38" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                        <rect x="5" y="15" width="28" height="18" rx="3.5"/>
                        <path d="M5 20h28" stroke-width="1.5" opacity=".4"/>
                        <path d="M12 6c0-2 1.2-3.5 3.5-3.5S19 4 19 6v9M19 6c0-2 1.2-3.5 3.5-3.5S26 4 26 6v9"/>
                        <circle cx="14" cy="27" r="2" fill="currentColor" stroke="none" opacity=".5"/>
                        <circle cx="24" cy="27" r="2" fill="currentColor" stroke="none" opacity=".5"/>
                    </svg>
                </div>
                <h1 class="ai-hero-title">企业AI落地管理系统</h1>
                <p class="ai-hero-tagline">ENTERPRISE · AI MANAGEMENT SYSTEM</p>
                <ul class="ai-hero-points">
                    <li><span class="ai-dot"></span>多行业适配 · 灵活配置业务流程</li>
                    <li><span class="ai-dot"></span>智能 AI 对话 · 语音/图片多模态交互</li>
                    <li><span class="ai-dot"></span>数据驱动决策 · 实时营运数据概览</li>
                </ul>
            </div>
            <div class="ai-hero-foot">&copy; 2026 富强科技</div>
        </section>

        {{-- 右侧表单 --}}
        <section class="ai-form-side">
            <div class="ai-form-wrap">
                <div class="ai-fm-badge">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                </div>
                <h2 class="ai-fm-title">欢迎登录</h2>
                <p class="ai-fm-sub">请输入账号密码以进入管理后台</p>

                {{ $slot }}

                <p class="ai-fm-foot">企业智能管理 · 安全授权访问</p>
            </div>
        </section>

        {{ \Filament\Support\Facades\FilamentView::renderHook(\Filament\View\PanelsRenderHook::FOOTER, scopes: $renderHookScopes) }}
        {{ \Filament\Support\Facades\FilamentView::renderHook(\Filament\View\PanelsRenderHook::SIMPLE_LAYOUT_END, scopes: $renderHookScopes) }}
    </div>
</x-filament-panels::layout.base>
