<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SsoUser;
use App\Models\Store;
use App\Models\User;
use App\Services\JwtService;
use App\Services\SsoAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/**
 * SSO 单点登录（桥接换本地 JWT）。
 *
 * 小程序把账号密码交给本控制器 → 代理 Auth Center 登录 → 映射/创建本地用户 →
 * 签发本项目自家 token（与 AuthController::login 同形状）→ 之后整套 API/auth.hybrid 零改动。
 */
class SsoAuthController extends Controller
{
    public function __construct(private SsoAuthService $sso) {}

    /**
     * 主入口：账号密码 → Auth Center → 本地会话。小程序使用。
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'identifier' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        $result = $this->sso->login($request->string('identifier'), $request->string('password'));

        return $this->issueLocalSession($result['user'] ?? [], $result['accessToken'] ?? null, $result['refreshToken'] ?? null);
    }

    /**
     * 注册入口：账号密码 → Auth Center 建号 → 本地会话（同 login 形状，注册后自动登录）。网页 /register 使用。
     */
    public function register(Request $request): JsonResponse
    {
        // 校验规则对齐认证中心自己的要求（username 3~50 位字母/数字/下划线，password 8~100 位），
        // 提前在本地拦，避免把不合规的请求转发过去才由认证中心报错
        $request->validate([
            'username' => ['required', 'string', 'min:3', 'max:50', 'regex:/^\w+$/'],
            'password' => ['required', 'string', 'min:8', 'max:100'],
            'name' => ['nullable', 'string'],
            'email' => ['nullable', 'email'],
        ]);

        $result = $this->sso->register(
            $request->string('username'),
            $request->string('password'),
            $request->filled('name') ? $request->string('name')->toString() : null,
            $request->filled('email') ? $request->string('email')->toString() : null,
        );

        return $this->issueLocalSession($result['user'] ?? [], $result['accessToken'] ?? null, $result['refreshToken'] ?? null);
    }

    /**
     * 备用入口：已持有 Auth Center accessToken（如微信 OAuth 回调）→ 验签 → 本地会话。
     */
    public function exchange(Request $request): JsonResponse
    {
        $request->validate([
            'accessToken' => ['required', 'string'],
        ]);

        $claims = $this->sso->verifyAccessToken($request->string('accessToken'));

        if (! $claims || ! isset($claims->sub)) {
            throw ValidationException::withMessages([
                'accessToken' => ['accessToken 无效或已过期'],
            ]);
        }

        return $this->issueLocalSession(['id' => (string) $claims->sub]);
    }

    /**
     * 透传刷新 Auth Center token（桥接下本地 JWT 当前无 exp，小程序 v1 未用，为规范保留）。
     */
    public function refresh(Request $request): JsonResponse
    {
        $request->validate([
            'refreshToken' => ['required', 'string'],
        ]);

        return response()->json($this->sso->refresh($request->string('refreshToken')));
    }

    /**
     * 映射/创建本地用户 → 解析门店 → 签发本地 token（同 AuthController::login 形状）。
     *
     * @param  array<string,mixed>  $ssoUser  Auth Center 用户对象（含 id/username/email）
     * @param  string|null  $ssoAccessToken  Auth Center 原生 accessToken（透传给客户端，用于访问认证中心生态内的其他服务，
     *                                        如 ai.xingke888.com——那些服务认的是认证中心签的 token，不认本项目自家 jwt_token）
     * @param  string|null  $ssoRefreshToken  Auth Center refreshToken（accessToken 仅 15 分钟有效，客户端用这个在用到时现换新的）
     */
    private function issueLocalSession(array $ssoUser, ?string $ssoAccessToken = null, ?string $ssoRefreshToken = null): JsonResponse
    {
        $user = $this->resolveLocalUser($ssoUser);
        $storeId = $user->resolveStoreId();

        $token = $user->createToken('auth_token', ['store:'.$storeId], now()->addDays(30))->plainTextToken;
        $jwtToken = app(JwtService::class)->issueForUser($user, $storeId);

        $store = $storeId ? Store::find($storeId, ['id', 'name']) : null;

        return response()->json([
            'message' => '登录成功',
            'token' => $token,
            'jwt_token' => $jwtToken,
            'sso_access_token' => $ssoAccessToken,
            'sso_refresh_token' => $ssoRefreshToken,
            'store_id' => $storeId,
            'store_name' => $store?->name,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'is_admin' => $user->is_admin,
                'store_id' => $storeId,
                'store_name' => $store?->name,
            ],
        ]);
    }

    /**
     * SSO 用户 → 本地用户映射：
     *   1. sso_users.sso_user_id 命中 → 复用其本地用户
     *   2. 否则按 email 命中本地 users → 建映射并复用（含其门店角色）
     *   3. 否则新建本地用户 + 映射（无门店角色 → resolveStoreId() 兜底默认店）
     *
     * @param  array<string,mixed>  $ssoUser
     *
     * @throws ValidationException Auth Center 未返回用户标识
     */
    private function resolveLocalUser(array $ssoUser): User
    {
        $ssoUserId = isset($ssoUser['id']) ? (string) $ssoUser['id'] : '';

        if ($ssoUserId === '') {
            throw ValidationException::withMessages([
                'identifier' => ['认证中心未返回用户标识'],
            ]);
        }

        $mapping = SsoUser::with('user')->where('sso_user_id', $ssoUserId)->first();
        if ($mapping && $mapping->user) {
            return $mapping->user;
        }

        $email = isset($ssoUser['email']) && is_string($ssoUser['email']) ? $ssoUser['email'] : null;
        $username = isset($ssoUser['username']) && is_string($ssoUser['username']) ? $ssoUser['username'] : null;

        $user = $email ? User::where('email', $email)->first() : null;

        if (! $user) {
            $user = User::create([
                'name' => $username ?: ($email ? Str::before($email, '@') : 'SSO 用户'),
                'username' => $username,
                'email' => $email ?: $ssoUserId.'@sso.local',
                'password' => Hash::make(Str::random(40)),
            ]);
        }

        SsoUser::create([
            'sso_user_id' => $ssoUserId,
            'user_id' => $user->id,
        ]);

        return $user;
    }
}
