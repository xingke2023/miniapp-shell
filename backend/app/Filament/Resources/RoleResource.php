<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RoleResource\Pages;
use App\Models\Permission;
use App\Models\Role;
use Filament\Forms;
use Filament\Schemas;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class RoleResource extends Resource
{
    protected static ?string $model = Role::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-shield-check';

    protected static string | \UnitEnum | null $navigationGroup = '系统管理';

    protected static ?string $navigationLabel = '角色权限';

    protected static ?string $modelLabel = '角色';

    protected static ?int $navigationSort = 10;

    /** 模块显示名映射 */
    public static array $moduleLabels = [
        'dashboard' => '🏠 工作台',
        'inventory' => '📦 库存管理',
        'purchase' => '🛒 进货管理',
        'products' => '🥦 商品管理',
        'suppliers' => '🏭 供应商',
        'expenses' => '💰 财务支出',
        'resumes' => '👤 人才库',
        'ai_assistant' => '🤖 AI 助手',
        'reports' => '📊 报表分析',
        'competitor' => '🔍 竞品情报',
        'users' => '👥 用户管理',
        'roles' => '🔑 角色权限',
    ];

    public static function form(Schema $schema): Schema
    {
        $permsByModule = Permission::query()
            ->orderBy('module')
            ->orderBy('id')
            ->get()
            ->groupBy('module');

        $permSections = [];

        foreach ($permsByModule as $module => $perms) {
            $label = static::$moduleLabels[$module] ?? $module;

            $permSections[] = Schemas\Components\Section::make($label)
                ->collapsible()
                ->schema([
                    Forms\Components\CheckboxList::make("perm_{$module}")
                        ->label('')
                        ->options($perms->pluck('name', 'id')->toArray())
                        ->columns(3)
                        ->gridDirection('row')
                        ->afterStateHydrated(function (Forms\Components\CheckboxList $component, $state, ?Role $record) use ($perms) {
                            if (! $record) {
                                return;
                            }
                            $assigned = $record->permissions()
                                ->whereIn('permissions.id', $perms->pluck('id'))
                                ->pluck('permissions.id')
                                ->toArray();
                            $component->state($assigned);
                        })
                        ->dehydrated(false),
                ])
                ->columns(1);
        }

        return $form
            ->schema([
                Schemas\Components\Section::make('基本信息')
                    ->columns(2)
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('角色名称')
                            ->required()
                            ->maxLength(100),

                        Forms\Components\TextInput::make('code')
                            ->label('角色代码')
                            ->required()
                            ->maxLength(50)
                            ->placeholder('如 STORE_MANAGER')
                            ->helperText('英文大写，唯一标识'),

                        Forms\Components\Select::make('scope')
                            ->label('适用范围')
                            ->options([1 => '总部', 2 => '区域', 3 => '门店'])
                            ->default(3)
                            ->required(),

                        Forms\Components\Textarea::make('description')
                            ->label('描述')
                            ->columnSpanFull()
                            ->rows(2),
                    ]),

                Schemas\Components\Section::make('权限矩阵')
                    ->description('勾选该角色拥有的操作权限')
                    ->schema($permSections)
                    ->collapsible(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('角色名称')
                    ->searchable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('code')
                    ->label('代码')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\TextColumn::make('scope')
                    ->label('范围')
                    ->formatStateUsing(fn (int $state) => match ($state) {
                        1 => '总部', 2 => '区域', 3 => '门店', default => '—',
                    })
                    ->badge()
                    ->color(fn (int $state) => match ($state) {
                        1 => 'danger', 2 => 'warning', 3 => 'info', default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('permissions_count')
                    ->label('权限数')
                    ->counts('permissions')
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('description')
                    ->label('描述')
                    ->limit(50)
                    ->placeholder('—'),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('更新时间')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make()
                    ->before(function (Role $record) {
                        // 禁止删除内置4个核心角色
                        if (array_key_exists($record->code, Role::$coreRoles)) {
                            \Filament\Notifications\Notification::make()
                                ->title('不能删除内置角色')
                                ->danger()
                                ->send();
                            $this->halt();
                        }
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRoles::route('/'),
            'create' => Pages\CreateRole::route('/create'),
            'edit' => Pages\EditRole::route('/{record}/edit'),
        ];
    }
}
