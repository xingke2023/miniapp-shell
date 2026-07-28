<?php

namespace Database\Factories;

use App\Models\CustomerOrder;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CustomerOrder>
 */
class CustomerOrderFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'store_id' => 1,
            'order_no' => CustomerOrder::generateOrderNo(),
            'customer_id' => null,
            'customer_name' => $this->faker->name(),
            'customer_phone' => $this->faker->numerify('1##########'),
            'type' => 1,
            'status' => 1,
            'total_amount' => 0,
            'discount_amount' => 0,
            'paid_amount' => 0,
        ];
    }
}
