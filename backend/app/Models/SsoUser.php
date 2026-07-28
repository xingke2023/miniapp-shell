<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SsoUser extends Model
{
    /** @var list<string> */
    protected $fillable = [
        'sso_user_id',
        'user_id',
    ];

    /** 关联的本地用户 */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
