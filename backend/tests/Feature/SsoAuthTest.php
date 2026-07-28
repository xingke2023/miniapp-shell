<?php

use App\Models\Organization;
use App\Models\Role;
use App\Models\SsoUser;
use App\Models\Store;
use App\Models\User;
use App\Models\UserStoreRole;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

/** Auth Center /auth/login 成功信封 {success:true, data:{accessToken, refreshToken, user}}。 */
function fakeSsoLogin(array $user): void
{
    Http::fake([
        '*/auth/login' => Http::response([
            'success' => true,
            'data' => [
                'accessToken' => 'sso.access.token',
                'refreshToken' => 'sso.refresh.token',
                'user' => $user,
            ],
        ], 200),
    ]);
}

it('新 SSO 用户首次登录：建本地用户 + sso_users 映射 + 兜底默认门店', function () {
    fakeSsoLogin(['id' => 'sso-1001', 'username' => 'alice', 'email' => 'alice@ext.com']);

    $res = $this->postJson('/api/auth/sso/login', [
        'identifier' => 'alice',
        'password' => 'secret',
    ]);

    $res->assertOk()
        ->assertJsonStructure(['token', 'jwt_token', 'store_id', 'user' => ['id', 'email', 'store_id']]);

    expect($res->json('store_id'))->toBe((int) config('store.default_id', 1));

    $this->assertDatabaseHas('users', ['email' => 'alice@ext.com', 'username' => 'alice']);
    $this->assertDatabaseHas('sso_users', ['sso_user_id' => 'sso-1001']);

    // 签发的本地 JWT 真能过 auth.hybrid
    $me = $this->withToken($res->json('jwt_token'))->getJson('/api/me');
    $me->assertOk();
});

it('同一 sso_user_id 重复登录不重复建用户', function () {
    fakeSsoLogin(['id' => 'sso-1001', 'username' => 'alice', 'email' => 'alice@ext.com']);

    $this->postJson('/api/auth/sso/login', ['identifier' => 'alice', 'password' => 'secret'])->assertOk();
    $this->postJson('/api/auth/sso/login', ['identifier' => 'alice', 'password' => 'secret'])->assertOk();

    expect(User::where('email', 'alice@ext.com')->count())->toBe(1);
    expect(SsoUser::where('sso_user_id', 'sso-1001')->count())->toBe(1);
});

it('email 命中已有本地用户：复用该用户及其门店', function () {
    $org = Organization::create(['name' => '测试组织', 'code' => 'ORG'.fake()->unique()->numerify('###')]);
    $store = Store::create([
        'organization_id' => $org->id, 'region_id' => null,
        'name' => '复用门店', 'code' => 'ST'.fake()->unique()->numerify('###'), 'status' => 1,
    ]);
    $role = Role::create(['organization_id' => $org->id, 'name' => '店员', 'code' => 'CLERK'.fake()->unique()->numerify('##'), 'scope' => 3]);

    $existing = User::factory()->create(['email' => 'bob@ext.com']);
    UserStoreRole::create(['user_id' => $existing->id, 'store_id' => $store->id, 'role_id' => $role->id]);

    fakeSsoLogin(['id' => 'sso-2002', 'username' => 'bob', 'email' => 'bob@ext.com']);

    $res = $this->postJson('/api/auth/sso/login', ['identifier' => 'bob', 'password' => 'secret']);

    $res->assertOk();
    expect($res->json('user.id'))->toBe($existing->id);
    expect($res->json('store_id'))->toBe($store->id);
    expect(User::where('email', 'bob@ext.com')->count())->toBe(1);
    $this->assertDatabaseHas('sso_users', ['sso_user_id' => 'sso-2002', 'user_id' => $existing->id]);
});

it('Auth Center 返回 401 → 接口 422 凭证错误', function () {
    Http::fake([
        '*/auth/login' => Http::response([
            'success' => false,
            'error' => ['code' => 'INVALID_CREDENTIALS', 'message' => '账号或密码错误'],
        ], 401),
    ]);

    $this->postJson('/api/auth/sso/login', ['identifier' => 'x', 'password' => 'y'])
        ->assertStatus(422)
        ->assertJsonValidationErrors('identifier');
});

it('缺字段 → 422', function () {
    $this->postJson('/api/auth/sso/login', [])->assertStatus(422);
});
