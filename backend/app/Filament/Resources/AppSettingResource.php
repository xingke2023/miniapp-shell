<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AppSettingResource\Pages;
use App\Models\AppSetting;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class AppSettingResource extends Resource
{
    protected static ?string $model = AppSetting::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static string | \UnitEnum | null $navigationGroup = '系统';

    protected static ?string $navigationLabel = '应用设置';

    protected static ?string $modelLabel = '应用设置';

    protected static ?string $pluralModelLabel = '应用设置';

    protected static ?int $navigationSort = 21;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('label')
                    ->label('说明')
                    ->maxLength(100)
                    ->placeholder('小程序顶部标题'),
                Forms\Components\TextInput::make('key')
                    ->label('设置键')
                    ->required()
                    ->maxLength(100)
                    ->helperText('英文唯一键，如 miniprogram_title；创建后不建议修改')
                    ->disabledOn('edit'),
                Forms\Components\Textarea::make('value')
                    ->label('值')
                    ->rows(2)
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('sort_order')
                    ->label('排序')
                    ->numeric()
                    ->default(0),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('label')->label('说明')->searchable(),
                Tables\Columns\TextColumn::make('key')->label('设置键')->searchable()->badge(),
                Tables\Columns\TextColumn::make('value')->label('值')->limit(50),
                Tables\Columns\TextColumn::make('sort_order')->label('排序')->sortable(),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('sort_order');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAppSettings::route('/'),
            'create' => Pages\CreateAppSetting::route('/create'),
            'edit' => Pages\EditAppSetting::route('/{record}/edit'),
        ];
    }
}
