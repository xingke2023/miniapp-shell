<?php

namespace App\Http\Middleware;

use App\Models\DailyOperationLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * 记录失败的 API 调用（4xx/5xx）到 daily_operation_logs。
 * 仅记录已认证用户（已知 store_id）的请求。
 */
class LogApiFailures
{
    /** 不需要记录的路径前缀 */
    private const SKIP_PATHS = [
        'api/login',
        'api/register',
        'api/logout',
        'api/me',
        'up',
    ];

    public function handle(Request $request, Closure $next): Response
    {
        return $next($request);
    }

    public function terminate(Request $request, Response $response): void
    {
        $status = $response->getStatusCode();

        if ($status < 400) {
            return;
        }

        $path = $request->path();

        foreach (self::SKIP_PATHS as $skip) {
            if ($path === $skip || str_starts_with($path, $skip.'/')) {
                return;
            }
        }

        $user = $request->user();
        if (! $user) {
            return;
        }

        $storeId = $user->resolveStoreId();
        if (! $storeId) {
            return;
        }

        $responseData = json_decode($response->getContent(), true);
        $errorMessage = $responseData['message'] ?? $responseData['error'] ?? "HTTP {$status}";

        // 截断过长的错误信息
        if (mb_strlen($errorMessage) > 500) {
            $errorMessage = mb_substr($errorMessage, 0, 497).'...';
        }

        $method = $request->method();
        $content = "[失败 {$status}] {$method} /{$path}";

        DailyOperationLog::write(
            storeId: $storeId,
            content: $content,
            intent: 'error',
            source: 2,
            isOperational: false,
            operatorId: $user->id,
            isFailed: true,
            httpStatusCode: $status,
            errorMessage: $errorMessage,
        );
    }
}
