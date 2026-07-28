<?php

namespace App\Filament\Resources\RoleResource\Pages;

use App\Filament\Resources\RoleResource;
use App\Models\Permission;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRole extends EditRecord
{
    protected static string $resource = RoleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function afterSave(): void
    {
        $this->syncPermissions();
    }

    private function syncPermissions(): void
    {
        $allPerms = Permission::query()->get()->keyBy('id');
        $selected = [];

        foreach ($this->data as $key => $value) {
            if (str_starts_with($key, 'perm_') && is_array($value)) {
                foreach ($value as $permId) {
                    if ($allPerms->has($permId)) {
                        $selected[] = $permId;
                    }
                }
            }
        }

        $this->record->permissions()->sync($selected);
    }
}
