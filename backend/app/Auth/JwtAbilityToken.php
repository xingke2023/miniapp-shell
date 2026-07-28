<?php

namespace App\Auth;

/**
 * JWT 认证时挂载到 User 的轻量 token 对象。
 *
 * 实现 Sanctum HasApiTokens::withAccessToken() 所需的 abilities 接口，
 * 使 User::resolveStoreId() 无需任何改动即可正常读取 store_id。
 */
class JwtAbilityToken
{
    /** @var string[] */
    public array $abilities;

    /** @param string[] $abilities */
    public function __construct(array $abilities)
    {
        $this->abilities = $abilities;
    }

    public function can(string $ability): bool
    {
        return in_array($ability, $this->abilities, true);
    }

    public function cant(string $ability): bool
    {
        return ! $this->can($ability);
    }

    /** JWT 是无状态的，logout 时无需删除任何记录。 */
    public function delete(): void {}
}
