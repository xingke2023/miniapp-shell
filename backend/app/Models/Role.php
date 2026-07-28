<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Role extends Model
{
    protected $fillable = ['organization_id', 'name', 'code', 'description', 'scope'];

    public static array $scopeLabels = [1 => '总部', 2 => '区域', 3 => '门店'];

    public static array $coreRoles = [
        'SUPER_ADMIN' => ['name' => '总部总负责人', 'scope' => 1],
        'REGION_BUYER' => ['name' => '区域采购',     'scope' => 2],
        'STORE_MANAGER' => ['name' => '门店店长',     'scope' => 3],
        'STORE_STAFF' => ['name' => '门店店员',     'scope' => 3],
    ];

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function permissions(): BelongsToMany
    {
        return $this->belongsToMany(Permission::class, 'role_permissions');
    }

    public function userStoreRoles(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(UserStoreRole::class);
    }

    public function hasPermission(string $code): bool
    {
        return $this->permissions->contains('code', $code);
    }

    public function scopeLabel(): string
    {
        return static::$scopeLabels[$this->scope] ?? '未知';
    }
}
