<?php

namespace App\Filament\Resources;

use App\Filament\Resources\IndustryResource\Pages;
use App\Models\Industry;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class IndustryResource extends Resource
{
    protected static ?string $model = Industry::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-building-storefront';

    protected static bool $shouldRegisterNavigation = false;

    protected static string|\UnitEnum|null $navigationGroup = '系统';

    protected static ?string $navigationLabel = '行业模版';

    protected static ?string $modelLabel = '行业模版';

    protected static ?string $pluralModelLabel = '行业模版';

    protected static ?int $navigationSort = 19;


    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('行业名称')
                    ->required()
                    ->maxLength(50)
                    ->placeholder('生鲜门店'),

                Forms\Components\TextInput::make('slug')
                    ->label('标识 slug')
                    ->required()
                    ->maxLength(50)
                    ->helperText('英文唯一标识，与「快捷按钮」的所属行业对应，创建后不建议修改')
                    ->disabledOn('edit'),

                Forms\Components\TextInput::make('emoji')
                    ->label('图标 Emoji')
                    ->maxLength(16)
                    ->placeholder('🥬'),

                Forms\Components\TextInput::make('title')
                    ->label('品牌标题')
                    ->maxLength(100)
                    ->helperText('进入该行业后，聊天页顶栏显示的标题')
                    ->placeholder('舌尖生鲜'),

                Forms\Components\TextInput::make('description')
                    ->label('行业说明')
                    ->maxLength(200)
                    ->helperText('选择页卡片副标题')
                    ->columnSpanFull(),

                Forms\Components\Textarea::make('greeting')
                    ->label('欢迎语')
                    ->rows(6)
                    ->maxLength(1000)
                    ->helperText('进入该行业聊天页、登录后展示的欢迎语；换行直接回车。留空则用「我是{品牌标题}」通用兜底')
                    ->columnSpanFull(),

                Forms\Components\TextInput::make('api_base')
                    ->label('外部后端 base')
                    ->maxLength(200)
                    ->placeholder('https://app2.xingke888.com/api')
                    ->helperText('留空=用本项目；填了则该行业的菜单/标题/接口都走这个外部后端（如进销存及CRM 指向 app2）')
                    ->columnSpanFull(),

                Forms\Components\TextInput::make('api_token')
                    ->label('外部服务账号 Token')
                    ->helperText('填写后小程序选此行业时直接使用此 token 调外部后端，无需用户登录。')
                    ->password()
                    ->revealable()
                    ->columnSpanFull(),

                Forms\Components\TextInput::make('ai_path')
                    ->label('AI 聊天接口路径')
                    ->maxLength(200)
                    ->placeholder('/ai/message')
                    ->helperText('外部行业 AI 聊天的接口路径，留空默认 /ai/message。示例：/api/chat/message')
                    ->columnSpanFull(),

                Forms\Components\TextInput::make('sort_order')
                    ->label('排序（小在前）')
                    ->numeric()
                    ->default(0),

                Forms\Components\Toggle::make('enabled')
                    ->label('启用')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('emoji')->label('图标'),
                Tables\Columns\TextColumn::make('name')->label('行业名称')->searchable(),
                Tables\Columns\TextColumn::make('slug')->label('标识')->badge()->searchable(),
                Tables\Columns\TextColumn::make('title')->label('品牌标题')->limit(30),
                Tables\Columns\IconColumn::make('enabled')->label('启用')->boolean(),
                Tables\Columns\TextColumn::make('sort_order')->label('排序')->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('enabled')->label('启用'),
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
            'index' => Pages\ListIndustries::route('/'),
            'create' => Pages\CreateIndustry::route('/create'),
            'edit' => Pages\EditIndustry::route('/{record}/edit'),
        ];
    }
}
