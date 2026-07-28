<?php

return [
    // 文字处理 — DeepSeek
    'base_url' => env('AI_BASE_URL', 'https://api.deepseek.com/v1'),
    'api_key' => env('AI_API_KEY', ''),
    'model' => env('AI_MODEL', 'deepseek-chat'),

    // 图像识别 — 第三方
    'vision_base_url' => env('AI_VISION_BASE_URL', env('AI_BASE_URL')),
    'vision_api_key' => env('AI_VISION_API_KEY', env('AI_API_KEY')),
    'vision_model' => env('AI_VISION_MODEL', 'gemini-3-flash-preview'),

    // 语音转文字 — 第三方
    'whisper_base_url' => env('AI_WHISPER_BASE_URL', env('AI_BASE_URL')),
    'whisper_api_key' => env('AI_WHISPER_API_KEY', env('AI_API_KEY')),
    'whisper_model' => env('AI_WHISPER_MODEL', 'whisper-1'),
];
