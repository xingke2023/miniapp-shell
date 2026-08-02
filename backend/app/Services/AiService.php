<?php

namespace App\Services;

use App\Models\AppSetting;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AiService
{
    private PendingRequest $client;

    private PendingRequest $visionClient;

    private PendingRequest $whisperClient;

    private string $model;

    private string $visionModel;

    private string $whisperModel;

    public function __construct()
    {
        // 文字 → DeepSeek
        $this->client = Http::baseUrl(config('ai.base_url'))
            ->withToken(config('ai.api_key'))
            ->timeout(60);

        // 图像 → 第三方
        $this->visionClient = Http::baseUrl(config('ai.vision_base_url'))
            ->withToken(config('ai.vision_api_key'))
            ->timeout(60);

        // 语音 → 第三方
        $this->whisperClient = Http::baseUrl(config('ai.whisper_base_url'))
            ->withToken(config('ai.whisper_api_key'))
            ->timeout(60);

        $this->model = config('ai.model');
        $this->visionModel = config('ai.vision_model');
        $this->whisperModel = config('ai.whisper_model');
    }

    /**
     * 解析用户输入的库存意图，返回结构化 JSON。
     *
     * @return array{intent: string, items: array, reply: string}
     */
    /**
     * @param  array<string,mixed>  $settingsOverride  模板专属设置（覆盖全局 AppSetting）
     */
    public function parseInventoryIntent(string $text, ?string $imageBase64 = null, string $knowledgeContext = '', array $settingsOverride = []): array
    {
        $brandName = (string) ($settingsOverride['brand_name'] ?? AppSetting::get('brand_name', ''));
        $storeType = (string) ($settingsOverride['store_type'] ?? AppSetting::get('store_type', '门店'));
        $systemPrompt = <<<PROMPT
你是{$storeType}AI助手（{$brandName}）。识别用户意图，严格只返回以下JSON，不要其他文字：

{
  "intent": "purchase_receipt|sale_report|sold_out|remaining|stocktake|waste_report|inventory_query|sales_today_query|daily_overview_query|purchase_orders_query|daily_logs_query|weather_query|refund_claims_query|suggestions_query|product_query|customer_add|follow_up_add|customer_query|customer_orders_query|other",
  "date": "YYYY-MM-DD或null（查询类意图若用户指定了日期则填写）",
  "items": [{"product_name":"商品名","qty":数字,"unit":"单位","action":"in|sell|sold_out|remaining|out|adjust","reason":"损耗原因（仅waste_report时填写，如：变质/破损/过期/虫害）"}],
  "customer": {"name":"顾客姓名或null","phone":"手机号或null","content":"跟进内容（follow_up_add时填写）或null"},
  "reply": "简短中文回复"
}

【写入类意图】
- purchase_receipt：进货到货，如"收到50斤胡萝卜"（action=in）
- sale_report：报售出量，如"卖了20斤苹果"（action=sell）
- sold_out：商品卖完，如"苹果卖完了"（action=sold_out，qty=0）
- remaining：报剩余量，如"番茄还剩5斤"（action=remaining）
- stocktake：盘点，如"白菜现有30斤"（action=adjust）
- waste_report：损耗/变质，如"豆腐坏了10斤"、"番茄烂了5斤"（action=out，reason填写损耗原因）

【查询类意图（reply返回"正在为您查询…"）】
- inventory_query：查当前库存，如"查库存"、"现在有什么货"、"还剩多少"（items返回空数组）
- product_query：查询某个特定商品的完整情况，如"草莓怎么样"、"白菜的情况"、"番茄卖得如何"，items填写[{"product_name":"商品名"}]
- sales_today_query：查今日/历史销售，如"今天卖了多少"、"昨天营业额"、"哪天收入"，可带日期
- daily_overview_query：查每日概览，如"今天情况"、"今日总览"、"开盘情况"，可带日期
- purchase_orders_query：查进货单，如"今天进了什么"、"进货记录"，可带日期
- daily_logs_query：查操作日志，如"今天做了什么"、"操作记录"、"日志"
- weather_query：询问天气，如"今天天气"、"会下雨吗"、"明天天气"，可带日期，reply返回"正在为您查询天气…"
- refund_claims_query：查供应商退款申请，如"退款申请情况"、"哪些损耗可以索赔"、"供应商退货进度"
- suggestions_query：查进货/促销建议，如"今天备什么货"、"有什么建议"、"哪些货要补"、"哪些要促销"

【客户(CRM)类意图】（这些意图 items 必须返回空数组，顾客信息放入 customer 字段）
- customer_add：新增顾客/会员，如"添加会员张三 13800138000"、"录入客户李四"（customer.name 必填，customer.phone 可选，reply确认已添加）
- follow_up_add：给某顾客加一条跟进记录，如"给张三加跟进：电话回访意向复购"（customer.name 标识顾客，customer.content 填跟进内容）
- customer_query：查某顾客档案/消费情况，如"查会员张三"、"客户李四的情况"（customer.name 或 customer.phone 标识，reply返回"正在为您查询…"）
- customer_orders_query：查顾客订单，如"张三的订单"、"待发货的订单"、"查顾客订单"（customer 可选，reply返回"正在为您查询…"）

【其他】
- other：与以上均无关

单位规范：斤/个/箱/袋/瓶/千克/克，未说明默认"斤"。qty非负数。

【图片识别专项规则（有图片时优先适用）】
图片可能是：进货单/送货单/磅码单/收据/手写单据/货架照片/商品标签。
- 若图片是进货单/送货单/磅码单：intent=purchase_receipt，从图片中提取所有商品名和数量，action=in
- 若图片是货架/库存照片：intent=stocktake，识别可见商品及估算数量，action=adjust
- 若图片是销售小票/零售收据：intent=sale_report，提取商品和数量，action=sell
- 商品名优先用中文简称（如"西红柿"→"番茄"、"土豆"→"土豆"）
- 数量单位从图片读取，若无单位信息则默认"斤"
- 若图片模糊/无法识别，intent=other，reply说明无法识别并返回空items
- reply字段必须先描述识别结果（如"我识别到这是一张进货单，共X种商品：番茄50斤、胡萝卜30斤"），再询问用户（"已为您录入，如有出入请告知"）
PROMPT;

        if (! empty($knowledgeContext)) {
            $systemPrompt .= "\n\n【知识库参考资料】\n以下内容可能与问题相关，回答 reply 字段时优先参考，知识库无关内容则按通用知识回答：\n\n{$knowledgeContext}";
        }

        $messages = [
            ['role' => 'system', 'content' => $systemPrompt],
        ];

        if ($imageBase64) {
            // 图像输入 → 第三方视觉模型
            $messages[] = [
                'role' => 'user',
                'content' => [
                    ['type' => 'text', 'text' => $text ?: '请识别图片。如果是进货单/送货单/磅码单，提取所有商品名称和数量录入进货；如果是货架或库存照片，识别商品和估算数量；如果是销售小票，提取售出商品和数量。'],
                    ['type' => 'image_url', 'image_url' => ['url' => 'data:image/jpeg;base64,'.$imageBase64]],
                ],
            ];

            $response = $this->visionClient->post('/chat/completions', [
                'model' => $this->visionModel,
                'messages' => $messages,
                'max_tokens' => 4000,
            ]);
        } else {
            // 纯文字
            $messages[] = ['role' => 'user', 'content' => $text];

            $response = $this->client->post('/chat/completions', [
                'model' => $this->model,
                'messages' => $messages,
                'max_tokens' => 4000,
            ]);
        }

        if ($response->failed()) {
            Log::error('AI API error', ['status' => $response->status(), 'body' => $response->body()]);

            return [
                'intent' => 'other',
                'items' => [],
                'reply' => 'AI服务暂时不可用，请稍后重试。',
            ];
        }

        $content = $response->json('choices.0.message.content', '{}');
        $parsed = json_decode($this->extractJson($content), true);

        if (! is_array($parsed)) {
            return [
                'intent' => 'other',
                'items' => [],
                'reply' => '无法解析您的输入，请描述商品名称和数量，例如：收到50斤胡萝卜。',
            ];
        }

        return $parsed;
    }

    /**
     * 从模型返回里提取 JSON：兼容被 ```json 代码块包裹或前后有解释文字的情况
     * （Claude 等模型不支持 response_format=json_object，靠提示词返回 JSON）。
     */
    private function extractJson(string $content): string
    {
        $s = trim($content);
        if (str_starts_with($s, '```')) {
            $s = preg_replace('/^```(?:json)?\s*/', '', $s);
            $s = preg_replace('/\s*```$/', '', $s);
        }
        $start = strpos($s, '{');
        $end = strrpos($s, '}');
        if ($start !== false && $end !== false && $end > $start) {
            return substr($s, $start, $end - $start + 1);
        }

        return $s;
    }

    /**
     * 语音文件转文字 — 第三方 Whisper 兼容接口。
     */
    public function transcribeVoice(string $filePath): string
    {
        $response = $this->whisperClient
            ->attach('file', file_get_contents($filePath), basename($filePath))
            ->post('/audio/transcriptions', [
                'model' => $this->whisperModel,
                'language' => 'zh',
            ]);

        if ($response->failed()) {
            Log::error('Whisper API error', ['status' => $response->status(), 'body' => $response->body()]);

            return '';
        }

        return $response->json('text', '');
    }
}
