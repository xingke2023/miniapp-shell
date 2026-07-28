<?php

namespace App\Http\Middleware;

use App\Auth\JwtAbilityToken;
use App\Models\User;
use App\Services\JwtService;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class JwtOrSanctumAuth
{
    public function __construct(private readonly JwtService $jwtService) {}

    public function handle(Request $request, Closure $next): Response
    {
        $bearer = $request->bearerToken();

        if ($bearer !== null && $this->isJwt($bearer)) {
            return $this->authenticateViaJwt($request, $next, $bearer);
        }

        // 不是 JWT（opaque Sanctum token 或无 token）→ 交给 Sanctum guard 处理
        return $this->authenticateViaSanctum($request, $next);
    }

    /**
     * JWT 是三段 Base64url 字符串，用 "." 分隔。
     */
    private function isJwt(string $token): bool
    {
        return substr_count($token, '.') === 2;
    }

    private function authenticateViaJwt(Request $request, Closure $next, string $token): Response
    {
        $claims = $this->jwtService->decode($token);

        if (! $claims) {
            return response()->json(['message' => 'Unauthenticated.'], Response::HTTP_UNAUTHORIZED);
        }

        $user = User::find($claims->sub);

        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], Response::HTTP_UNAUTHORIZED);
        }

        $user->withAccessToken(new JwtAbilityToken(['store:'.(int) $claims->store_id]));
        Auth::setUser($user);

        return $next($request);
    }

    private function authenticateViaSanctum(Request $request, Closure $next): Response
    {
        $user = Auth::guard('sanctum')->user();

        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], Response::HTTP_UNAUTHORIZED);
        }

        Auth::setUser($user);

        return $next($request);
    }
}
