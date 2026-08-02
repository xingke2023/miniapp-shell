<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\JwtService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminSsoController extends Controller
{
    /**
     * 用小程序的 JWT 免登录进入 Filament 后台：校验 JWT → 登入 web 会话 → 跳转 /admin。
     * 避免在微信 web-view 里走 Livewire 登录表单（session/CSRF 在 web-view 不稳定，按钮一直转）。
     */
    public function __invoke(Request $request, JwtService $jwt): RedirectResponse
    {
        $token = (string) $request->query('token', '');
        $claims = $token !== '' ? $jwt->decode($token) : null;
        $user = $claims ? User::find($claims->sub) : null;

        if (! $user) {
            return redirect('/admin/login');
        }

        if ($user->is_admin) {
            Auth::guard('web')->login($user, true);
            $request->session()->regenerate();

            return redirect('/admin');
        }

        // 非管理员用户：带 JWT 跳转前端，由 AuthProvider 完成自动登录
        return redirect('/?token=' . urlencode($token));
    }
}
