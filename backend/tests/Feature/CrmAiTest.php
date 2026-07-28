<?php

use App\Models\Customer;
use App\Services\AiService;
use Illuminate\Foundation\Testing\RefreshDatabase;

use function Pest\Laravel\mock;

uses(RefreshDatabase::class);

// 复用 CustomerApiTest.php 的 crmActor()。

function mockAi(array $parsed): void
{
    mock(AiService::class)
        ->shouldReceive('parseInventoryIntent')
        ->andReturn($parsed);
}

it('AI 意图 customer_add 新建顾客', function () {
    [$user, $store, $bearer] = crmActor();
    mockAi([
        'intent' => 'customer_add',
        'items' => [],
        'customer' => ['name' => '张三', 'phone' => '13800138000', 'content' => null],
        'reply' => '已添加会员张三',
    ]);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/ai/message', ['text' => '添加会员张三 13800138000']);

    $res->assertOk()->assertJsonPath('intent', 'customer_add');
    $c = Customer::where('store_id', $store->id)->where('name', '张三')->first();
    expect($c)->not->toBeNull();
    expect($c->phone)->toBe('13800138000');
    expect($c->source)->toBe(2);
});

it('AI 意图 follow_up_add 给顾客加跟进', function () {
    [$user, $store, $bearer] = crmActor();
    $customer = Customer::factory()->create(['store_id' => $store->id, 'name' => '李四', 'phone' => '13900001111']);
    mockAi([
        'intent' => 'follow_up_add',
        'items' => [],
        'customer' => ['name' => '李四', 'phone' => null, 'content' => '电话回访，意向复购'],
        'reply' => '已记录跟进',
    ]);

    $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/ai/message', ['text' => '给李四加跟进：电话回访'])
        ->assertOk();

    expect($customer->followUps()->count())->toBe(1);
    expect($customer->followUps()->first()->content)->toBe('电话回访，意向复购');
});

it('AI 意图 customer_query 返回顾客卡片', function () {
    [$user, $store, $bearer] = crmActor();
    Customer::factory()->create(['store_id' => $store->id, 'name' => '王五', 'phone' => '13700002222', 'total_spent' => 500]);
    mockAi([
        'intent' => 'customer_query',
        'items' => [],
        'customer' => ['name' => '王五', 'phone' => null, 'content' => null],
        'reply' => '正在为您查询…',
    ]);

    $res = $this->withHeader('Authorization', 'Bearer '.$bearer)
        ->postJson('/api/ai/message', ['text' => '查会员王五']);

    $res->assertOk()
        ->assertJsonPath('card_type', 'customers')
        ->assertJsonPath('card_data.data.0.name', '王五');
});
