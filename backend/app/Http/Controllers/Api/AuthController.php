<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Models\User;
use App\Services\JwtService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'login' => ['required', 'string'],
            'password' => ['required'],
            'store_id' => ['nullable', 'integer'],
        ]);

        $login = $request->input('login');
        $field = filter_var($login, FILTER_VALIDATE_EMAIL) ? 'email' : 'username';
        $user = User::where($field, $login)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'login' => ['用户名/邮箱或密码错误'],
            ]);
        }

        // 解析用户可访问的门店列表（有效期内）
        $accessibleStoreIds = $user->storeRoles()
            ->where(fn ($q) => $q->whereNull('expired_at')->orWhere('expired_at', '>', now()))
            ->pluck('store_id')
            ->unique()
            ->values();

        // 「暂不区分门店」：登录不再强制选门店。
        // 优先级：显式指定 store_id → 唯一门店 → 默认门店（若在可访问列表内）→ 可访问的第一个 → 默认门店。
        $defaultStoreId = (int) config('store.default_id', 1);
        $requestedStoreId = $request->integer('store_id') ?: null;

        if ($requestedStoreId) {
            // 显式指定：非管理员且有门店绑定时，必须在可访问列表内
            if (! $user->is_admin && $accessibleStoreIds->isNotEmpty() && ! $accessibleStoreIds->contains($requestedStoreId)) {
                return response()->json(['message' => '无权访问该门店'], 403);
            }
            $storeId = $requestedStoreId;
        } elseif ($accessibleStoreIds->count() === 1) {
            $storeId = $accessibleStoreIds->first();
        } elseif ($accessibleStoreIds->isNotEmpty()) {
            $storeId = $accessibleStoreIds->contains($defaultStoreId) ? $defaultStoreId : $accessibleStoreIds->first();
        } else {
            // 无任何门店绑定（含未绑店的管理员）：回退默认门店
            $storeId = $defaultStoreId;
        }

        // 将 store_id 编码进 token ability，后续请求从 token 中读取
        $token = $user->createToken('auth_token', ['store:'.$storeId], now()->addDays(30))->plainTextToken;
        $jwtToken = app(JwtService::class)->issueForUser($user, $storeId);

        $store = $storeId ? Store::find($storeId, ['id', 'name']) : null;

        return response()->json([
            'message' => '登录成功',
            'token' => $token,
            'jwt_token' => $jwtToken,
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

    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()?->currentAccessToken();

        // 仅真正的 Sanctum PersonalAccessToken 可在服务端删除；
        // JWT（无状态，JwtAbilityToken）与会话（TransientToken）没有 delete()，跳过即可。
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        $storeId = $user->resolveStoreId();

        // 当前门店下的角色
        $roles = $storeId
            ? $user->storeRoles()
                ->where('store_id', $storeId)
                ->where(fn ($q) => $q->whereNull('expired_at')->orWhere('expired_at', '>', now()))
                ->with('role:id,code,name')
                ->get()
                ->pluck('role.code')
                ->filter()
                ->values()
            : collect();

        $store = $storeId ? Store::find($storeId, ['id', 'name', 'address']) : null;

        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
                'is_admin' => $user->is_admin,
                'store_id' => $storeId,
                'store_name' => $store?->name,
                'store_address' => $store?->address,
                'roles' => $roles,
            ],
        ]);
    }
}
