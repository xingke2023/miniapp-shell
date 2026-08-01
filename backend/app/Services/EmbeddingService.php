<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class EmbeddingService
{
    public function embed(string $text): ?array
    {
        if (empty(trim($text))) {
            return null;
        }

        $baseUrl = config('ai.embedding_base_url');
        $apiKey  = config('ai.embedding_api_key');
        $model   = config('ai.embedding_model');

        if (empty($baseUrl) || empty($apiKey) || empty($model)) {
            return null;
        }

        try {
            $response = Http::baseUrl($baseUrl)
                ->withToken($apiKey)
                ->timeout(30)
                ->post('/embeddings', [
                    'model' => $model,
                    'input' => $text,
                ]);

            if ($response->failed()) {
                Log::warning('Embedding API error', [
                    'status' => $response->status(),
                    'body'   => $response->body(),
                ]);

                return null;
            }

            return $response->json('data.0.embedding');
        } catch (\Throwable $e) {
            Log::warning('Embedding request failed', ['error' => $e->getMessage()]);

            return null;
        }
    }

    public function toVectorLiteral(array $embedding): string
    {
        return '[' . implode(',', $embedding) . ']';
    }
}
