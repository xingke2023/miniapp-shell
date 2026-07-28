<?php

namespace Database\Factories;

use App\Models\Customer;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Customer>
 */
class CustomerFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'store_id' => 1,
            'name' => $this->faker->name(),
            'phone' => $this->faker->numerify('1##########'),
            'gender' => $this->faker->numberBetween(0, 2),
            'level' => 1,
            'points' => 0,
            'total_spent' => 0,
            'order_count' => 0,
            'tags' => [],
            'source' => 1,
            'status' => 1,
        ];
    }
}
