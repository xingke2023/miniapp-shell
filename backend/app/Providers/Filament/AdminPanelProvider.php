<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationGroup;
use Filament\Navigation\NavigationItem;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\View\PanelsRenderHook;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\Support\HtmlString;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->brandName('企业AI落地作业系统')
            ->brandLogo(null)
            ->brandLogoHeight('2.5rem')
            ->viteTheme('resources/css/filament/admin/theme.css')
            ->renderHook(
                PanelsRenderHook::HEAD_END,
                fn (): HtmlString => new HtmlString('<style>.fi-sidebar-header .fi-logo, .fi-simple-header .fi-logo { font-size: 1.3rem !important; font-weight: 200 !important; letter-spacing: .03em !important; }</style>'),
            )
            ->colors([
                'primary' => Color::Amber,
            ])
            ->navigationGroups([
                NavigationGroup::make('前端系统'),
                NavigationGroup::make('业务系统'),
                NavigationGroup::make('企业知识库(AI版)'),
                NavigationGroup::make('系统管理'),
                NavigationGroup::make('供应商及商品'),
                NavigationGroup::make('销售管理'),
                NavigationGroup::make('财务收支'),
                NavigationGroup::make('人才库'),
            ])
            ->navigationItems([
                NavigationItem::make('订单系统')
                    ->group('业务系统')
                    ->icon('heroicon-o-shopping-cart')
                    ->url(fn () => \App\Filament\Pages\ComingSoon::getUrl())
                    ->sort(1),
                NavigationItem::make('CRM系统')
                    ->group('业务系统')
                    ->icon('heroicon-o-user-group')
                    ->url(fn () => \App\Filament\Pages\ComingSoon::getUrl())
                    ->sort(2),
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
