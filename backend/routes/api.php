<?php

use App\Http\Controllers\Api\AiAssistantController;
use App\Http\Controllers\Api\AppConfigController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChatLogController;
use App\Http\Controllers\Api\IndustryController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\QuickActionController;
use App\Http\Controllers\Api\SsoAuthController;
use App\Http\Controllers\Api\WeatherController;
use App\Http\Controllers\Api\WeworkCallbackController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::get('/app-config', [AppConfigController::class, 'index']);
Route::get('/industries', [IndustryController::class, 'index']);
Route::get('/quick-actions', [QuickActionController::class, 'index']);

// SSO 单点登录（外部 Auth Center，桥接换本地 JWT）
Route::post('/auth/sso/login', [SsoAuthController::class, 'login']);
Route::post('/auth/sso/register', [SsoAuthController::class, 'register']);
Route::post('/auth/sso/exchange', [SsoAuthController::class, 'exchange']);
Route::post('/auth/sso/refresh', [SsoAuthController::class, 'refresh']);

// Protected routes
Route::middleware('auth.hybrid')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // AI 助手
    Route::post('/ai/message', [AiAssistantController::class, 'message']);
    Route::post('/ai/voice', [AiAssistantController::class, 'voice']);
    Route::get('/ai/sessions', [AiAssistantController::class, 'sessions']);
    Route::get('/ai/sessions/{id}/messages', [AiAssistantController::class, 'sessionMessages']);

    // 天气查询
    Route::get('/weather', [WeatherController::class, 'query']);

    // Posts
    Route::apiResource('/posts', PostController::class)->only(['index', 'show', 'store', 'update', 'destroy']);
});

// Chat Logs
Route::middleware('auth.hybrid')->group(function () {
    Route::post('/chat-logs', [ChatLogController::class, 'store']);
    Route::get('/chat-logs', [ChatLogController::class, 'index']);
    Route::get('/chat-logs/conversation/{conversationId}', [ChatLogController::class, 'conversation']);
});

// 企业微信回调
Route::get('/wework/callback', [WeworkCallbackController::class, 'verify']);
Route::post('/wework/callback', [WeworkCallbackController::class, 'receive']);
