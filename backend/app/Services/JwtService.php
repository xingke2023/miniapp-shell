<?php

namespace App\Services;

use App\Models\User;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Throwable;

class JwtService
{
    private string $secret;

    private string $algo;

    public function __construct()
    {
        $this->secret = config('jwt.secret');
        $this->algo = config('jwt.algo', 'HS256');
    }

    /**
     * 为指定用户和门店签发 JWT（无过期时间）。
     */
    public function issueForUser(User $user, int $storeId): string
    {
        $payload = [
            'sub' => $user->id,
            'store_id' => $storeId,
            'name' => $user->name,
            'email' => $user->email,
            'is_admin' => $user->is_admin,
            'iat' => time(),
        ];

        return JWT::encode($payload, $this->secret, $this->algo);
    }

    /**
     * 验证并解码 JWT，失败返回 null。
     *
     * @return object{sub:int,store_id:int,name:string,email:string,is_admin:bool,iat:int}|null
     */
    public function decode(string $token): ?object
    {
        try {
            return JWT::decode($token, new Key($this->secret, $this->algo));
        } catch (Throwable) {
            return null;
        }
    }
}
