<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MessestandBild extends Model
{
    protected $table = 'messestand_bilder';

    public $timestamps = false;

    protected $fillable = [
        'bild',
    ];

    public function messestand(): BelongsTo
    {
        return $this->belongsTo(Messestand::class);
    }
}