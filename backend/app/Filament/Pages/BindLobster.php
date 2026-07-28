<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class BindLobster extends Page
{
    protected string $view = 'filament.pages.bind-lobster';

    protected static string | \UnitEnum | null $navigationGroup = '系统管理';

    protected static ?string $navigationLabel = '绑定龙虾';

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-link';

    protected static ?int $navigationSort = 99;

    public function getTitle(): string
    {
        return '绑定龙虾';
    }
}
