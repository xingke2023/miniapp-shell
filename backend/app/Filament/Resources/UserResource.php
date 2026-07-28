<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\Role;
use App\Models\Store;
use App\Models\User;
use Filament\Forms;
use Filament\Schemas;
use Filament\Schemas\Schema;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-users';

    protected static string | \UnitEnum | null $navigationGroup = '系统管理';

    protected static ?string $navigationLabel = '用户管理';

    protected static ?string $modelLabel = '用户';

    protected static ?int $navigationSort = 11;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Schemas\Components\Section::make('账户信息')
                    ->columns(2)
                    ->schema([
                        Forms\Components\TextInput::make('username')
                            ->label('用户名')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true)
                            ->helperText('用于登录，需全局唯一；建议小写字母/数字/下划线')
                            ->rule('regex:/^[a-zA-Z0-9_]+$/'),

                        Forms\Components\TextInput::make('name')
                            ->label('姓名')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('email')
                            ->label('邮箱')
                            ->email()
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true),

                        Forms\Components\TextInput::make('password')
                            ->label('密码')
                            ->password()
                            ->maxLength(255)
                            ->dehydrated(fn ($state) => filled($state))
                            ->required(fn (string $operation) => $operation === 'create')
                            ->helperText('编辑时留空则不修改密码'),

                        Forms\Components\Toggle::make('is_admin')
                            ->label('后台管理员')
                            ->helperText('开启后可登录 /admin 后台，拥有最高权限')
                            ->inline(false),
                    ]),

                Schemas\Components\Section::make('角色分配')
                    ->description('为用户分配门店角色，必须指定门店；角色仅限「门店店长」或「门店店员」')
                    ->schema([
                        Forms\Components\Repeater::make('storeRoles')
                            ->label('')
                            ->relationship()
                            ->schema([
                                Forms\Components\Select::make('store_id')
                                    ->label('门店')
                                    ->options(Store::query()->where('status', 1)->pluck('name', 'id'))
                                    ->searchable()
                                    ->required(),

                                Forms\Components\Select::make('role_id')
                                    ->label('角色')
                                    ->options(Role::query()
                                        ->whereIn('code', ['STORE_MANAGER', 'STORE_STAFF'])
                                        ->pluck('name', 'id'))
                                    ->required()
                                    ->searchable(),

                                Forms\Components\Hidden::make('granted_at')
                                    ->default(now()),
                            ])
                            ->columns(2)
                            ->addActionLabel('+ 添加角色')
                            ->defaultItems(fn (string $operation) => $operation === 'create' ? 1 : 0)
                            ->minItems(1)
                            ->reorderable(false),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('姓名')
                    ->searchable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('email')
                    ->label('邮箱')
                    ->searchable(),

                Tables\Columns\IconColumn::make('is_admin')
                    ->label('管理员')
                    ->boolean()
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('storeRoles')
                    ->label('角色')
                    ->badge()
                    ->state(fn (User $record) => $record->storeRoles->map(
                        fn ($sr) => ($sr->store ? $sr->store->name.' · ' : '').($sr->role?->name ?? '-')
                    )->all())
                    ->searchable(query: fn ($query, $search) => $query->whereHas(
                        'storeRoles.role',
                        fn ($q) => $q->where('name', 'like', "%{$search}%")
                    )),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('注册时间')
                    ->dateTime('Y-m-d')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('api_keys_count')
                    ->label('API Keys')
                    ->state(fn (User $record) => $record->tokens()->where('name', 'like', 'api:%')->count())
                    ->badge()
                    ->color('warning')
                    ->alignCenter(),
            ])
            ->modifyQueryUsing(fn ($query) => $query->with(['storeRoles.role', 'storeRoles.store']))
            ->filters([
                Tables\Filters\TernaryFilter::make('is_admin')
                    ->label('管理员'),
            ])
            ->actions([
                Actions\EditAction::make(),

                Actions\Action::make('generateApiKey')
                    ->label('生成 API Key')
                    ->icon('heroicon-o-key')
                    ->color('warning')
                    ->form([
                        Forms\Components\TextInput::make('description')
                            ->label('用途描述')
                            ->required()
                            ->placeholder('例如：门店机器人、企业微信集成')
                            ->maxLength(100),
                    ])
                    ->action(function (User $record, array $data): void {
                        $newToken = $record->createToken('api:'.$data['description']);
                        Notification::make()
                            ->title('API Key 已生成（仅显示一次，请立即复制）')
                            ->body($newToken->plainTextToken)
                            ->persistent()
                            ->success()
                            ->send();
                    }),

                Actions\Action::make('revokeApiKey')
                    ->label('撤销密钥')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->form([
                        Forms\Components\Select::make('token_id')
                            ->label('选择要撤销的密钥')
                            ->options(fn (User $record) => $record->tokens()
                                ->where('name', 'like', 'api:%')
                                ->get()
                                ->mapWithKeys(fn ($t) => [
                                    $t->id => str_replace('api:', '', $t->name)
                                        .' — 创建于 '.$t->created_at->format('Y-m-d')
                                        .($t->last_used_at ? '，最后使用 '.$t->last_used_at->format('Y-m-d') : '，从未使用'),
                                ])
                            )
                            ->required(),
                    ])
                    ->requiresConfirmation()
                    ->modalHeading('撤销 API Key')
                    ->modalDescription('撤销后该密钥立即失效，无法恢复。')
                    ->action(function (User $record, array $data): void {
                        $record->tokens()->where('id', $data['token_id'])->delete();
                        Notification::make()->title('密钥已撤销')->success()->send();
                    })
                    ->visible(fn (User $record) => $record->tokens()->where('name', 'like', 'api:%')->exists()),
            ])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
