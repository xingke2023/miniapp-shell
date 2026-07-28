<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChatLogResource\Pages;
use App\Models\ChatLog;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class ChatLogResource extends Resource
{
    protected static ?string $model = ChatLog::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationLabel = '对话日志';

    protected static string | \UnitEnum | null $navigationGroup = '系统';

    protected static ?string $modelLabel = '对话日志';

    protected static ?string $pluralModelLabel = '对话日志';

    protected static ?int $navigationSort = 10;

    public static function form(Schema $schema): Schema
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('agent_id')->label('Agent')->maxLength(100),
                Forms\Components\Select::make('direction')->label('方向')
                    ->options(['inbound' => '用户发', 'outbound' => 'Agent 回复'])
                    ->required(),
                Forms\Components\TextInput::make('channel')->label('渠道')->maxLength(50),
                Forms\Components\TextInput::make('conversation_id')->label('对话 ID')->maxLength(100),
                Forms\Components\TextInput::make('sender')->label('发送方')->maxLength(200),
                Forms\Components\Textarea::make('content')->label('消息内容')->columnSpanFull(),
                Forms\Components\Toggle::make('success')->label('发送成功'),
                Forms\Components\TextInput::make('error_msg')->label('失败原因')->maxLength(500),
                Forms\Components\DateTimePicker::make('occurred_at')->label('发生时间'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                Tables\Columns\TextColumn::make('occurred_at')
                    ->label('时间')
                    ->sortable()
                    ->formatStateUsing(fn ($state) => $state
                        ? \Carbon\Carbon::parse($state->toDateTimeString(), 'UTC')
                            ->setTimezone('Asia/Shanghai')
                            ->format('m-d H:i:s')
                        : '-'),
                Tables\Columns\BadgeColumn::make('direction')
                    ->label('方向')
                    ->formatStateUsing(fn ($state) => $state === 'inbound' ? '用户' : 'Agent')
                    ->colors(['success' => 'outbound', 'info' => 'inbound']),
                Tables\Columns\TextColumn::make('channel')
                    ->label('渠道')
                    ->badge()
                    ->searchable(),
                Tables\Columns\TextColumn::make('agent_id')
                    ->label('Agent')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('sender')
                    ->label('发送方')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('conversation_id')
                    ->label('对话 ID')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\ViewColumn::make('content')
                    ->label('内容')
                    ->searchable()
                    ->view('filament.columns.markdown-hover'),
                Tables\Columns\IconColumn::make('success')
                    ->label('成功')
                    ->boolean()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('direction')
                    ->label('方向')
                    ->options(['inbound' => '用户发', 'outbound' => 'Agent 回复']),
                Tables\Filters\SelectFilter::make('channel')
                    ->label('渠道')
                    ->options(['telegram' => 'Telegram', 'whatsapp' => 'WhatsApp']),
                Tables\Filters\Filter::make('occurred_at')
                    ->label('日期范围')
                    ->form([
                        Forms\Components\DatePicker::make('from')->label('从'),
                        Forms\Components\DatePicker::make('until')->label('至'),
                    ])
                    ->query(function ($query, array $data) {
                        return $query
                            ->when($data['from'], fn ($q) => $q->whereDate('occurred_at', '>=', $data['from']))
                            ->when($data['until'], fn ($q) => $q->whereDate('occurred_at', '<=', $data['until']));
                    }),
            ])
            ->actions([
                Actions\ViewAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $infolist
            ->schema([
                Infolists\Components\Grid::make(2)->schema([
                    Infolists\Components\TextEntry::make('occurred_at')->label('时间')
                        ->formatStateUsing(fn ($state) => $state
                            ? \Carbon\Carbon::parse($state->toDateTimeString(), 'UTC')
                                ->setTimezone('Asia/Shanghai')
                                ->format('Y-m-d H:i:s')
                            : '-'),
                    Infolists\Components\TextEntry::make('direction')->label('方向')
                        ->formatStateUsing(fn ($state) => $state === 'inbound' ? '用户发' : 'Agent 回复')
                        ->badge()
                        ->color(fn ($state) => $state === 'inbound' ? 'info' : 'success'),
                    Infolists\Components\TextEntry::make('agent_id')->label('Agent'),
                    Infolists\Components\TextEntry::make('channel')->label('渠道')->badge(),
                    Infolists\Components\TextEntry::make('sender')->label('发送方'),
                    Infolists\Components\TextEntry::make('conversation_id')->label('对话 ID'),
                ]),
                Infolists\Components\TextEntry::make('content')
                    ->label('消息内容')
                    ->markdown()
                    ->columnSpanFull(),
                Infolists\Components\TextEntry::make('error_msg')->label('失败原因')->columnSpanFull()->visible(fn ($record) => $record->error_msg),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChatLogs::route('/'),
            'view' => Pages\ViewChatLog::route('/{record}'),
        ];
    }
}
