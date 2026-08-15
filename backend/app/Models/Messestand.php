<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Skill;

class Messestand extends Model
{
    protected $table = 'messestaende';

    // Fields that can be mass assigned when creating or updating a messestand.
    protected $fillable = [
        'user_id',
        'title',
        'description',
        'price_from',
        'price_to',
        'featured',
    ];

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








    // Each einsatzgebiet belongs to one messestand.
    // Each messestand has one einsatzgebiet.
    public function einsatzgebiet()
    {
        return $this->hasOne(Einsatzgebiet::class);
    }

}
