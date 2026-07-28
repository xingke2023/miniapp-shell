<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MenuTemplateResource\Pages;
use App\Filament\Resources\MenuTemplateResource\RelationManagers\QuickActionsRelationManager;
use App\Models\Industry;
use App\Models\MenuTemplate;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class MenuTemplateResource extends Resource
{
    protected static ?string $model = MenuTemplate::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static bool $shouldRegisterNavigation = false;

    protected static string|\UnitEnum|null $navigationGroup = '系统';

    protected static ?string $navigationLabel = '菜单模版';

    protected static ?string $modelLabel = '菜单模版';

    protected static ?string $pluralModelLabel = '菜单模版';

    protected static ?int $navigationSort = 18;


    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('industry')
                    ->label('所属行业')
                    ->options(fn () => Industry::query()->orderBy('sort_order')->pluck('name', 'slug'))
                    ->searchable()
                    ->required()
                    ->helperText('该模版属于哪个行业；切换生效模版用列表里的「设为当前」'),

                Forms\Components\TextInput::make('name')
                    ->label('模版名')
                    ->required()
                    ->maxLength(50)
                    ->placeholder('默认模版 / 完整版 / 促销版'),

                Forms\Components\TextInput::make('sort_order')
                    ->label('排序（小在前）')
                    ->numeric()
                    ->default(0),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('industry')->label('行业')->badge()->searchable(),
                Tables\Columns\TextColumn::make('name')->label('模版名')->searchable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('当前生效')
                    ->boolean(),
                Tables\Columns\TextColumn::make('quick_actions_count')
                    ->label('按钮数')
                    ->counts('quickActions'),
                Tables\Columns\TextColumn::make('sort_order')->label('排序')->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('industry')
                    ->label('行业')
                    ->options(fn () => Industry::query()->orderBy('sort_order')->pluck('name', 'slug')),
            ])
            ->actions([
                Actions\Action::make('activate')
                    ->label('设为当前')
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn (MenuTemplate $record) => ! $record->is_active)
                    ->requiresConfirmation()
                    ->modalDescription('设为该行业当前生效的菜单，原生效模版将被取消。')
                    ->action(function (MenuTemplate $record): void {
                        MenuTemplate::query()
                            ->where('industry', $record->industry)
                            ->whereKeyNot($record->getKey())
                            ->update(['is_active' => false]);
                        $record->update(['is_active' => true]);

                        Notification::make()->success()->title('已设为当前生效模版')->send();
                    }),

                Actions\Action::make('duplicate')
                    ->label('复制模版')
                    ->icon('heroicon-o-document-duplicate')
                    ->color('gray')
                    ->requiresConfirmation()
                    ->modalDescription('复制本模版及其全部按钮（含子菜单项）为一份新模版（不生效）。')
                    ->action(function (MenuTemplate $record): void {
                        static::duplicateTemplate($record);

                        Notification::make()->success()->title('已复制模版')->send();
                    }),

                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('industry');
    }

    /**
     * 克隆模版 + 其全部按钮（连每个 menu 按钮的子菜单项）为一份新模版（不生效）。
     */
    protected static function duplicateTemplate(MenuTemplate $source): void
    {
        $copy = $source->replicate(['is_active']);
        $copy->name = $source->name.'（副本）';
        $copy->is_active = false;
        $copy->save();

        foreach ($source->quickActions()->with('items')->get() as $action) {
            $newAction = $action->replicate(['menu_template_id']);
            $newAction->menu_template_id = $copy->id;
            $newAction->save();

            foreach ($action->items as $item) {
                $newItem = $item->replicate(['quick_action_id']);
                $newItem->quick_action_id = $newAction->id;
                $newItem->save();
            }
        }
    }

    public static function getRelations(): array
    {
        return [
            QuickActionsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMenuTemplates::route('/'),
            'create' => Pages\CreateMenuTemplate::route('/create'),
            'edit' => Pages\EditMenuTemplate::route('/{record}/edit'),
        ];
    }
}
