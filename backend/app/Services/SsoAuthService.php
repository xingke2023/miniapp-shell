<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;
use Throwable;

/**
 * 外部 Auth Center（mo.xingke888.com）客户端。
 *
 * Auth Center 响应统一信封：成功 {success:true, data:{...}}，失败 {success:false, error:{code,message}}。
 * unwrap() 兼容信封或扁平结构（data ?? 顶层）。
 */
class SsoAuthService
{
    private PendingRequest $client;

    public function __construct()
    {
        $this->client = Http::baseUrl(config('sso.base_url'))
            ->acceptJson()
            ->timeout((int) config('sso.timeout', 15));
    }

    /**
     * 账号密码登录 Auth Center。
     *
     * @return array{accessToken:string,refreshToken?:string,user?:array<string,mixed>}
     *
     * @throws ValidationException 凭证错误或认证中心不可用
     */
    public function login(string $identifier, string $password): array
    {
        try {
            $response = $this->client->post('/auth/login', [
                'identifier' => $identifier,
                'password' => $password,
            ]);
        } catch (Throwable $e) {
            throw ValidationException::withMessages([
                'identifier' => ['认证中心暂不可用，请稍后再试'],
            ]);
        }

        if ($response->failed()) {
            throw ValidationException::withMessages([
                'identifier' => [$this->errorMessage($response->json(), '用户名/邮箱或密码错误')],
            ]);
        }

        return $this->unwrap($response->json());
    }

    /**
     * 账号密码注册 Auth Center。
     *
     * @return array{accessToken:string,refreshToken?:string,user?:array<string,mixed>}
     *
     * @throws ValidationException 用户名已存在或认证中心不可用
     */
    public function register(string $username, string $password, ?string $name = null, ?string $email = null): array
    {
        $payload = ['username' => $username, 'password' => $password];
        if ($name !== null && $name !== '') {
            $payload['name'] = $name;
        }
        if ($email !== null && $email !== '') {
            $payload['email'] = $email;
        }

        try {
            $response = $this->client->post('/auth/register', $payload);
        } catch (Throwable $e) {
            throw ValidationException::withMessages([
                'username' => ['认证中心暂不可用，请稍后再试'],
            ]);
        }

        if ($response->failed()) {
            throw ValidationException::withMessages([
                'username' => [$this->errorMessage($response->json(), '注册失败')],
            ]);
        }

        return $this->unwrap($response->json());
    }

    /**
     * 刷新 Auth Center token。
     *
     * @return array{accessToken:string,refreshToken?:string}
     *
     * @throws ValidationException refreshToken 失效
     */
    public function refresh(string $refreshToken): array
    {
        try {
            $response = $this->client->post('/token/refresh', [
                'refreshToken' => $refreshToken,
            ]);
        } catch (Throwable $e) {
            throw ValidationException::withMessages([
                'refreshToken' => ['认证中心暂不可用，请稍后再试'],
            ]);
        }

        if ($response->failed()) {
            throw ValidationException::withMessages([
                'refreshToken' => [$this->errorMessage($response->json(), 'refreshToken 已失效，请重新登录')],
            ]);
        }

        return $this->unwrap($response->json());
    }

    /**
     * 验证 Auth Center accessToken 签名（HS256 + sso.jwt_secret），失败返回 null。
     *
     * @return object{sub:string,exp?:int}|null
     */
    public function verifyAccessToken(string $accessToken): ?object
    {
        try {
            return JWT::decode($accessToken, new Key((string) config('sso.jwt_secret'), config('sso.algo', 'HS256')));
        } catch (Throwable) {
            return null;
        }
    }

    /**
     * 解包 Auth Center 信封：优先 data，否则取顶层。
     *
     * @param  array<string,mixed>|null  $body
     * @return array<string,mixed>
     */
    private function unwrap(?array $body): array
    {
        if (! is_array($body)) {
            return [];
        }

        return isset($body['data']) && is_array($body['data']) ? $body['data'] : $body;
    }

    /**
     * 从 Auth Center 错误信封提取可读 message。
     *
     * @param  array<string,mixed>|null  $body
     */
    private function errorMessage(?array $body, string $fallback): string
    {
        if (is_array($body) && isset($body['error']['message']) && is_string($body['error']['message'])) {
            return $body['error']['message'];
        }

        return $fallback;
    }
}
