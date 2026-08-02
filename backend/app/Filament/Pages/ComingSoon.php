<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class ComingSoon extends Page
{
    protected static bool $shouldRegisterNavigation = false;

    protected string $view = 'filament.pages.coming-soon';
}
