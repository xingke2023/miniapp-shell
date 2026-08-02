<?php

namespace App\Filament\Resources\MenuTemplateResource\Pages;

use App\Filament\Resources\MenuTemplateResource;
use App\Filament\Resources\QuickActionResource;
use App\Models\QuickAction;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Pages\ManageRelatedRecords;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ManageMenuQuickActions extends ManageRelatedRecords
{
    protected static string $resource = MenuTemplateResource::class;

    protected static string $relationship = 'quickActions';

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-squares-2x2';

    public function getTitle(): string|\Illuminate\Contracts\Support\Htmlable
    {
        return $this->getOwnerRecord()->name;
    }

    public function getBreadcrumb(): string
    {
        return '菜单按钮';
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('editTemplate')
                ->label('编辑模版信息')
                ->icon('heroicon-o-pencil')
                ->modalHeading('编辑模版信息')
                ->form([
                    Forms\Components\TextInput::make('name')
                        ->label('模版名')
                        ->required()
                        ->maxLength(50),
                    Forms\Components\TextInput::make('sort_order')
                        ->label('排序（小在前）')
                        ->numeric()
                        ->default(0),
                ])
                ->fillForm(fn () => $this->getOwnerRecord()->only('name', 'sort_order'))
                ->action(fn (array $data) => $this->getOwnerRecord()->update($data)),
        ];
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('label')
                    ->label('按钮文字')
                    ->required()
                    ->maxLength(50),

                Forms\Components\Select::make('action_type')
                    ->label('按钮类型')
                    ->options([
                        'prompt'        => '发文字给 AI',
                        'web'           => 'AI 摘要+网页',
                        'open'          => '打开网页（带 token）',
                        'external_open' => '外部网站（带 token）',
                        'menu'          => '弹出子菜单',
                        'shortcuts'     => '展开快捷按钮到聊天区',
                        'route'         => '小程序原生页',
                        'external'      => '外部网站（不带 token）',
                    ])
                    ->default('prompt')
                    ->required()
                    ->live(),

                Forms\Components\TextInput::make('key')->label('Key')->required()->maxLength(50),
                Forms\Components\TextInput::make('badge')->label('角标')->maxLength(20),
                Forms\Components\TextInput::make('sort_order')->label('排序')->numeric()->default(0),
                Forms\Components\Toggle::make('enabled')->label('启用')->default(true)->inline(),
                Forms\Components\Toggle::make('admin_only')->label('仅管理员可见')->inline(),

                Forms\Components\Toggle::make('show_in_chat')
                    ->label('聊天区显示')
                    ->inline()
                    ->visible(fn (Get $get) => $get('action_type') === 'menu'),

                Forms\Components\Textarea::make('prompt')
                    ->label('发给 AI 的文字')->rows(2)->columnSpanFull()
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['prompt', 'web']))
                    ->required(fn (Get $get) => in_array($get('action_type'), ['prompt', 'web'])),

                Forms\Components\TextInput::make('target_path')
                    ->label('路径 / 网址')->maxLength(200)->columnSpanFull()
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['web', 'open', 'external_open', 'route', 'external']))
                    ->required(fn (Get $get) => in_array($get('action_type'), ['web', 'open', 'external_open', 'route', 'external'])),

                Forms\Components\TextInput::make('target_title')
                    ->label('网页标题')->maxLength(50)
                    ->visible(fn (Get $get) => in_array($get('action_type'), ['web', 'open', 'external_open'])),

                Forms\Components\TextInput::make('web_label')
                    ->label('「打开完整页」按钮文字')->maxLength(50)
                    ->visible(fn (Get $get) => $get('action_type') === 'web'),
            ])
            ->columns(3);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('sort_order')->label('序')->sortable(),
                Tables\Columns\TextColumn::make('label')->label('按钮文字')->searchable(),
                Tables\Columns\TextColumn::make('action_type')
                    ->label('类型')
                    ->badge()
                    ->formatStateUsing(fn ($state) => [
                        'prompt'        => '发给 AI',
                        'web'           => 'AI+网页',
                        'open'          => '打开网页',
                        'external_open' => '外部网站',
                        'menu'          => '子菜单',
                        'shortcuts'     => '快捷行',
                        'route'         => '原生页',
                        'external'      => '外链',
                    ][$state] ?? $state)
                    ->color(fn ($state) => match ($state) {
                        'menu', 'shortcuts' => 'warning',
                        'open', 'external_open', 'external' => 'info',
                        'web' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('items_count')
                    ->label('子项数')
                    ->counts('items')
                    ->badge()
                    ->color('warning'),
                Tables\Columns\IconColumn::make('admin_only')->label('仅管理员')->boolean(),
                Tables\Columns\IconColumn::make('enabled')->label('启用')->boolean(),
            ])
            ->defaultSort('sort_order')
            ->headerActions([
                Actions\CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $data['menu_template_id'] = $this->getOwnerRecord()->id;
                        $data['industry'] = $this->getOwnerRecord()->industry;

                        return $data;
                    }),
            ])
            ->actions([
                Actions\Action::make('edit')
                    ->label('编辑')
                    ->icon('heroicon-m-pencil-square')
                    ->url(fn (QuickAction $record) => QuickActionResource::getUrl('edit', ['record' => $record]))
                    ->openUrlInNewTab(false),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}
