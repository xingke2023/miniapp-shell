<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Collection;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'is_admin',
        'menu_template_id',
        'ai_enabled',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_admin' => 'boolean',
        'ai_enabled' => 'boolean',
        ];
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->is_admin;
    }

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    public function menuTemplate(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(MenuTemplate::class);
    }

    public function storeRoles(): HasMany
    {
        return $this->hasMany(UserStoreRole::class);
    }

    /** 用户所有角色（跨门店/区域） */
    public function roles(): Collection
    {
        return $this->storeRoles()
            ->with('role.permissions')
            ->get()
            ->pluck('role')
            ->filter()
            ->unique('id')
            ->values();
    }

    /** 用户所有权限码（合并所有角色） */
    public function allPermissions(): Collection
    {
        if ($this->is_admin) {
            return Permission::query()->pluck('code');
        }

        return $this->roles()
            ->flatMap(fn (Role $role) => $role->permissions->pluck('code'))
            ->unique()
            ->values();
    }

    public function hasPermission(string $code): bool
    {
        if ($this->is_admin) {
            return true;
        }

        return $this->allPermissions()->contains($code);
    }

    public function hasRole(string $roleCode): bool
    {
        if ($this->is_admin) {
            return true;
        }

        return $this->roles()->contains('code', $roleCode);
    }

    /** 普通用户的主门店 ID（从有效的 user_store_roles 读取） */
    public function primaryStoreId(): ?int
    {
        return $this->storeRoles()
            ->where(function ($q) {
                $q->whereNull('expired_at')->orWhere('expired_at', '>', now());
            })
            ->value('store_id');
    }

    /**
     * 从当前 token 的 ability 中读取本次会话的门店 ID。
     *
     * 解析优先级：token 的 store:{id} ability → 用户主门店 → 默认门店（config('store.default_id')）。
     * 「暂不区分门店」阶段：永不返回 null，无门店关联时回退默认门店，避免接口 403。
     */
    public function resolveStoreId(): ?int
    {
        $token = $this->currentAccessToken();

        // PersonalAccessToken / JwtAbilityToken 才有 abilities；
        // 会话鉴权下 currentAccessToken() 是 Laravel\Sanctum\TransientToken，没有 abilities 属性，
        // 直接访问会抛 "Undefined property" → 用 isset 安全判断后再读，否则回退 primaryStoreId()。
        if ($token && isset($token->abilities) && is_array($token->abilities)) {
            foreach ($token->abilities as $ability) {
                if (is_string($ability) && str_starts_with($ability, 'store:')) {
                    return (int) substr($ability, 6);
                }
            }
        }

        return $this->primaryStoreId() ?? (int) config('store.default_id', 1);
    }
}
