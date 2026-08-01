<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AiMessage;
use App\Models\AiSession;
use App\Models\WeatherLog;
use App\Services\AiService;
use App\Services\KnowledgeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class AiAssistantController extends Controller
{
    public function __construct(
        private readonly AiService $aiService,
        private readonly KnowledgeService $knowledgeService,
    ) {}

    /**
     * 接收文字或图片输入，调用 AI 返回回复。
     */
    public function message(Request $request): JsonResponse
    {
        $request->validate([
            'text' => 'nullable|string|max:2000',
            'image_base64' => 'nullable|string',
            'session_id' => 'nullable|integer|exists:ai_sessions,id',
        ]);

        $startTime = microtime(true);

        $text = $request->input('text') ?? '';
        $imageBase64 = $request->input('image_base64');

        $inputType = 1;
        if ($imageBase64 && $text) {
            $inputType = 4;
        } elseif ($imageBase64) {
            $inputType = 3;
        }

        $session = $this->getOrCreateSession($request, $inputType);

        $knowledgeContext = $this->knowledgeService->formatContext(
            $this->knowledgeService->findRelevant($text)
        );

        $parsed = $this->aiService->parseInventoryIntent($text, $imageBase64, $knowledgeContext);

        $processingMs = (int) ((microtime(true) - $startTime) * 1000);

        AiMessage::create([
            'session_id' => $session->id,
            'role' => 1,
            'input_type' => $inputType,
            'raw_content' => $text,
            'image_urls' => $imageBase64 ? ['[base64 image]'] : null,
            'intent' => $parsed['intent'] ?? 'other',
            'entities' => $parsed['items'] ?? [],
            'created_at' => now(),
        ]);

        AiMessage::create([
            'session_id' => $session->id,
            'role' => 2,
            'input_type' => 1,
            'ai_response' => $parsed['reply'] ?? '',
            'processing_time_ms' => $processingMs,
            'created_at' => now(),
        ]);

        $cardType = null;
        $cardData = null;
        $intent = $parsed['intent'] ?? 'other';

        if ($intent === 'weather_query') {
            $date = $parsed['date'] ?? now()->toDateString();
            [$cardType, $cardData] = $this->fetchWeatherData($date, $session->store_id);
        }

        return response()->json([
            'reply' => $parsed['reply'] ?? '已收到您的信息。',
            'intent' => $intent,
            'card_type' => $cardType,
            'card_data' => $cardData,
            'session_id' => $session->id,
        ]);
    }

    /**
     * 接收语音文件，转文字后调用 AI。
     */
    public function voice(Request $request): JsonResponse
    {
        $request->validate([
            'audio' => 'required|file|mimes:mp3,wav,m4a,webm,ogg|max:25600',
            'session_id' => 'nullable|integer|exists:ai_sessions,id',
        ]);

        $startTime = microtime(true);

        $file = $request->file('audio');
        $filePath = $file->store('voice_temp', 'local');
        $fullPath = Storage::disk('local')->path($filePath);

        $transcribedText = $this->aiService->transcribeVoice($fullPath);

        Storage::disk('local')->delete($filePath);

        if (empty($transcribedText)) {
            return response()->json([
                'reply' => '语音识别失败，请重新录制或改用文字输入。',
                'intent' => 'other',
            ], 422);
        }

        $session = $this->getOrCreateSession($request, 2);

        $knowledgeContext = $this->knowledgeService->formatContext(
            $this->knowledgeService->findRelevant($transcribedText)
        );

        $parsed = $this->aiService->parseInventoryIntent($transcribedText, null, $knowledgeContext);
        $processingMs = (int) ((microtime(true) - $startTime) * 1000);

        AiMessage::create([
            'session_id' => $session->id,
            'role' => 1,
            'input_type' => 2,
            'transcribed_text' => $transcribedText,
            'intent' => $parsed['intent'] ?? 'other',
            'entities' => $parsed['items'] ?? [],
            'created_at' => now(),
        ]);

        AiMessage::create([
            'session_id' => $session->id,
            'role' => 2,
            'input_type' => 1,
            'ai_response' => $parsed['reply'] ?? '',
            'processing_time_ms' => $processingMs,
            'created_at' => now(),
        ]);

        $intent = $parsed['intent'] ?? 'other';
        $cardType = null;
        $cardData = null;

        if ($intent === 'weather_query') {
            $date = $parsed['date'] ?? now()->toDateString();
            [$cardType, $cardData] = $this->fetchWeatherData($date, $session->store_id);
        }

        return response()->json([
            'transcribed_text' => $transcribedText,
            'reply' => $parsed['reply'] ?? '已收到您的语音信息。',
            'intent' => $intent,
            'card_type' => $cardType,
            'card_data' => $cardData,
            'session_id' => $session->id,
        ]);
    }

    public function sessions(Request $request): JsonResponse
    {
        $sessions = AiSession::where('user_id', $request->user()->id)
            ->orderByDesc('started_at')
            ->paginate(20);

        return response()->json($sessions);
    }

    public function sessionMessages(Request $request, int $id): JsonResponse
    {
        $session = AiSession::where('user_id', $request->user()->id)->findOrFail($id);

        $messages = AiMessage::where('session_id', $session->id)
            ->orderBy('created_at')
            ->get();

        return response()->json($messages);
    }

    private function fetchWeatherData(string $date, int $storeId): array
    {
        $city = '香港';

        $existing = WeatherLog::where('date', $date)->where('city', $city)->first();
        if ($existing) {
            return ['weather', ['data' => [
                'city' => $city,
                'date' => $date,
                'condition' => $existing->weather,
                'temperature_high' => $existing->temperature_high,
                'temperature_low' => $existing->temperature_low,
                'humidity' => $existing->humidity,
                'rain_probability' => $existing->rain_probability,
                'suggestion' => $existing->description,
            ]]];
        }

        try {
            $response = Http::baseUrl(config('ai.base_url'))
                ->withToken(config('ai.api_key'))
                ->timeout(30)
                ->post('/chat/completions', [
                    'model' => config('ai.model'),
                    'messages' => [
                        ['role' => 'system', 'content' => '你是天气查询助手。严格只返回JSON，不要任何其他文字。'],
                        ['role' => 'user', 'content' => "查询{$city}在{$date}的天气。返回格式：{\"weather\":\"天气状况\",\"temperature_high\":最高气温整数,\"temperature_low\":最低气温整数,\"humidity\":湿度整数,\"rain_probability\":降雨概率整数,\"description\":\"一句话提示\"}"],
                    ],
                    'temperature' => 0.3,
                    'response_format' => ['type' => 'json_object'],
                ]);

            $weather = json_decode($response->json('choices.0.message.content', '{}'), true) ?? [];

            if (! empty($weather)) {
                WeatherLog::firstOrCreate(
                    ['date' => $date, 'city' => $city],
                    [
                        'store_id' => $storeId,
                        'weather' => $weather['weather'] ?? '',
                        'temperature_high' => $weather['temperature_high'] ?? 0,
                        'temperature_low' => $weather['temperature_low'] ?? 0,
                        'humidity' => $weather['humidity'] ?? 0,
                        'rain_probability' => $weather['rain_probability'] ?? 0,
                        'uv_index' => $weather['uv_index'] ?? 0,
                        'description' => $weather['description'] ?? '',
                    ]
                );
            }

            return ['weather', ['data' => array_merge(['city' => $city, 'date' => $date], $weather)]];
        } catch (\Throwable $e) {
            Log::error('Weather fetch failed', ['error' => $e->getMessage()]);

            return ['weather', ['data' => ['city' => $city, 'date' => $date]]];
        }
    }

    private function getOrCreateSession(Request $request, int $inputType): AiSession
    {
        if ($sessionId = $request->input('session_id')) {
            $session = AiSession::where('user_id', $request->user()->id)->find($sessionId);
            if ($session) {
                return $session;
            }
        }

        $channelMap = [1 => 2, 2 => 1, 3 => 3, 4 => 2];

        return AiSession::create([
            'store_id' => null,
            'user_id' => $request->user()->id,
            'channel' => $channelMap[$inputType] ?? 2,
            'status' => 1,
            'started_at' => now(),
        ]);
    }
}
