<?php

use App\Models\Organization;
use App\Models\Store;
use App\Models\User;
use Tests\TestCase;

/*
|--------------------------------------------------------------------------
| Test Case
|--------------------------------------------------------------------------
|
| The closure you provide to your test functions is always bound to a specific PHPUnit test
| case class. By default, that class is "PHPUnit\Framework\TestCase". Of course, you may
| need to change it using the "pest()" function to bind a different classes or traits.
|
*/

pest()->extend(TestCase::class)
 // ->use(Illuminate\Foundation\Testing\RefreshDatabase::class)
    ->in('Feature');

/*
|--------------------------------------------------------------------------
| Expectations
|--------------------------------------------------------------------------
|
| When you're writing tests, you often need to check that values meet certain conditions. The
| "expect()" function gives you access to a set of "expectations" methods that you can use
| to assert different things. Of course, you may extend the Expectation API at any time.
|
*/

expect()->extend('toBeOne', function () {
    return $this->toBe(1);
});

/*
|--------------------------------------------------------------------------
| Functions
|--------------------------------------------------------------------------
|
| While Pest is very powerful out-of-the-box, you may have some testing code specific to your
| project that you don't want to repeat in every file. Here you can also expose helpers as
| global functions to help you to reduce the number of lines of code in your test files.
|
*/

function something()
{
    // ..
}

/**
 * CRM/订单测试公用：建「门店 + 用户 + token(带 store ability)」，返回 [user, store, bearer]。
 * store_id / created_by / operator_id 均从该 token 解析。
 *
 * @return array{0: User, 1: Store, 2: string}
 */
function crmActor(?int $orgId = 1): array
{
    $org = new Organization(['name' => '测试组织', 'code' => 'ORG'.fake()->unique()->numerify('###')]);
    $org->id = $orgId;
    $org->save();
    $store = Store::create([
        'organization_id' => $org->id,
        'region_id' => null,
        'name' => '测试门店'.fake()->unique()->numerify('##'),
        'code' => 'ST'.fake()->unique()->numerify('###'),
        'status' => 1,
    ]);
    $user = User::factory()->create();
    $bearer = $user->createToken('test', ['store:'.$store->id])->plainTextToken;

    return [$user, $store, $bearer];
}
