<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\MenuTemplate;
use App\Models\User;
use App\Services\JwtService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AppConfigController extends Controller
{
    public function __construct(private readonly JwtService $jwt) {}

    /**
     * 公开的应用配置（小程序标题等品牌文案）。
     * 未携带 token：返回全局 AppSetting。
     * 携带有效 JWT 且绑定了菜单模板：模板专属设置覆盖全局（非空值才覆盖）。
     */
    public function index(Request $request): JsonResponse
    {
        $global = AppSetting::query()
            ->orderBy('sort_order')
            ->pluck('value', 'key')
            ->all();

        $user = $this->resolveOptionalUser($request);
        if ($user?->menu_template_id) {
            $tpl = MenuTemplate::find($user->menu_template_id);
            $override = array_filter(
                (array) ($tpl?->settings ?? []),
                fn ($v) => $v !== null && $v !== '',
            );
            $global = array_merge($global, $override);
        }

        return response()->json(['data' => $global]);
    }

    /** 尝试从 Bearer token 解析用户；无 token 或无效则返回 null（不抛错）。 */
    private function resolveOptionalUser(Request $request): ?User
    {
        $bearer = $request->bearerToken();
        if ($bearer === null) {
            return null;
        }

        // JWT（三段式）
        if (substr_count($bearer, '.') === 2) {
            $claims = $this->jwt->decode($bearer);

            return $claims ? User::find($claims->sub) : null;
        }

        // Sanctum opaque token
        return Auth::guard('sanctum')->user();
    }
}
