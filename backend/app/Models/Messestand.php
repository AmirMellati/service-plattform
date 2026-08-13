<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Skill;

class Messestand extends Model
{
    protected $table = 'messestaende';

    public function user()
{
    return $this->belongsTo(User::class);
}
//many to many relationship with skills
public function skills()
{
    return $this->belongsToMany(
        Skill::class,
        'messestand_skill_beziehung',
        'messestand_id',
        'skill_id'
    );
}

}
