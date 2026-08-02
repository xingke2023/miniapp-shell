<?php

namespace App\Filament\Resources\MenuTemplateResource\Pages;

use App\Filament\Resources\MenuTemplateResource;
use App\Models\Industry;
use App\Models\MenuTemplate;
use App\Models\QuickAction;
use App\Models\QuickActionItem;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Support\Facades\Storage;

class ListMenuTemplates extends ListRecords
{
    protected static string $resource = MenuTemplateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('import')
                ->label('导入模版')
                ->icon('heroicon-o-arrow-up-tray')
                ->color('gray')
                ->form([
                    Forms\Components\FileUpload::make('file')
                        ->label('JSON 文件')
                        ->acceptedFileTypes(['application/json', 'text/plain', 'application/octet-stream'])
                        ->disk('local')
                        ->directory('menu-imports')
                        ->required()
                        ->helperText('上传由「导出」功能生成的 .json 文件'),

                    Forms\Components\TextInput::make('name')
                        ->label('模版名（可选）')
                        ->placeholder('留空则使用文件中的名称')
                        ->maxLength(50),
                ])
                ->action(function (array $data): void {
                    $path = Storage::disk('local')->path($data['file']);
                    $json = json_decode(file_get_contents($path), true);
                    Storage::disk('local')->delete($data['file']);

                    if (! isset($json['actions'])) {
                        Notification::make()->danger()->title('文件格式不正确')->send();
                        return;
                    }

                    $template = MenuTemplate::create([
                        'industry'   => $json['industry'] ?? 'fresh',
                        'name'       => filled($data['name']) ? $data['name'] : ($json['name'].'（导入）'),
                        'is_active'  => false,
                        'sort_order' => 0,
                    ]);

                    foreach ($json['actions'] as $idx => $a) {
                        $action = QuickAction::create([
                            'menu_template_id' => $template->id,
                            'industry'         => $template->industry,
                            'key'              => $a['key'] ?? 'btn-'.$idx,
                            'emoji'            => $a['emoji'] ?? '',
                            'label'            => $a['label'] ?? '',
                            'badge'            => $a['badge'] ?? '',
                            'action_type'      => $a['action_type'] ?? 'prompt',
                            'prompt'           => $a['prompt'] ?? '',
                            'target_path'      => $a['target_path'] ?? '',
                            'target_title'     => $a['target_title'] ?? '',
                            'web_label'        => $a['web_label'] ?? '',
                            'admin_only'       => $a['admin_only'] ?? false,
                            'enabled'          => $a['enabled'] ?? true,
                            'sort_order'       => $a['sort_order'] ?? $idx,
                            'show_in_chat'     => $a['show_in_chat'] ?? false,
                        ]);

                        foreach ($a['items'] ?? [] as $si => $item) {
                            QuickActionItem::create([
                                'quick_action_id' => $action->id,
                                'emoji'           => $item['emoji'] ?? '',
                                'label'           => $item['label'] ?? '',
                                'desc'            => $item['desc'] ?? '',
                                'item_type'       => $item['item_type'] ?? 'prompt',
                                'route'           => $item['route'] ?? '',
                                'prompt'          => $item['prompt'] ?? '',
                                'sort_order'      => $item['sort_order'] ?? $si,
                                'show_in_chat'    => $item['show_in_chat'] ?? false,
                            ]);
                        }
                    }

                    Notification::make()
                        ->success()
                        ->title('导入成功')
                        ->body('已创建模版「'.$template->name.'」，共 '.count($json['actions']).' 个按钮。可在列表中「设为当前」生效。')
                        ->send();
                }),

            Actions\CreateAction::make(),
        ];
    }
}
