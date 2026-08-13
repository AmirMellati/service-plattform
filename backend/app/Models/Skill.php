<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Messestand;

class Skill extends Model
{

public function messestaende()
{
    return $this->belongsToMany(
        Messestand::class,
        'messestand_skill_beziehung',
        'skill_id',
        'messestand_id'
    );
}
    //
}
