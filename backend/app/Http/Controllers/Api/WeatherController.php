<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WeatherLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WeatherController extends Controller
{
    public function query(Request $request): JsonResponse
    {
        $date = $request->input('date', now()->toDateString());
        $city = $request->input('city', '香港');
        $storeId = $request->user()->resolveStoreId();

        // 先查 DB，已有记录直接返回
        $existing = WeatherLog::where('date', $date)->where('city', $city)->first();
        if ($existing) {
            return response()->json([
                'city' => $city,
                'date' => $date,
                'source' => 'cache',
                'data' => $existing->only([
                    'weather', 'temperature_high', 'temperature_low',
                    'humidity', 'rain_probability', 'uv_index', 'description',
                ]),
            ]);
        }

        $systemPrompt = '你是一个天气查询助手。用户会告诉你城市和日期，你需要返回该地天气情况。严格只返回JSON，不要任何其他文字。';

        $userPrompt = "查询{$city}在{$date}的天气。返回格式：
{
  \"weather\": \"天气状况（晴/多云/阵雨/大雨等）\",
  \"temperature_high\": 最高气温数字（摄氏度）,
  \"temperature_low\": 最低气温数字（摄氏度）,
  \"humidity\": 湿度百分比数字,
  \"rain_probability\": 降雨概率百分比数字,
  \"uv_index\": 紫外线指数数字（1-11）,
  \"description\": \"一句话天气提示，适合生鲜门店参考（如影响客流、商品保存注意事项）\"
}";

        try {
            $response = Http::baseUrl(config('ai.base_url'))
                ->withToken(config('ai.api_key'))
                ->timeout(30)
                ->post('/chat/completions', [
                    'model' => config('ai.model'),
                    'messages' => [
                        ['role' => 'system', 'content' => $systemPrompt],
                        ['role' => 'user', 'content' => $userPrompt],
                    ],
                    'temperature' => 0.3,
                    'thinking' => ['type' => 'enabled'],
                    'reasoning_effort' => 'high',
                ]);

            $content = $response->json('choices.0.message.content', '{}');

            // 去掉可能的 markdown 代码块包裹
            $content = preg_replace('/^```json\s*/i', '', trim($content));
            $content = preg_replace('/\s*```$/', '', $content);

            $weather = json_decode($content, true) ?? [];

            // 保存到数据库
            if (! empty($weather)) {
                WeatherLog::create([
                    'store_id' => $storeId,
                    'date' => $date,
                    'city' => $city,
                    'weather' => $weather['weather'] ?? '',
                    'temperature_high' => $weather['temperature_high'] ?? 0,
                    'temperature_low' => $weather['temperature_low'] ?? 0,
                    'humidity' => $weather['humidity'] ?? 0,
                    'rain_probability' => $weather['rain_probability'] ?? 0,
                    'uv_index' => $weather['uv_index'] ?? 0,
                    'description' => $weather['description'] ?? '',
                ]);
            }

            return response()->json([
                'city' => $city,
                'date' => $date,
                'source' => 'ai',
                'data' => $weather,
            ]);
        } catch (\Throwable $e) {
            Log::error('Weather query failed', ['error' => $e->getMessage()]);

            return response()->json(['error' => '天气查询失败，请稍后重试'], 500);
        }
    }
}
