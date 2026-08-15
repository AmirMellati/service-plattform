<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Profile extends Model
{
    // Fields that can be stored when creating or updating a profile.
    protected $fillable = [
        'user_id',
        'bio',
        'image',
        'street',
        'house_number',
        'postal_code',
        'city',
    ];
// Returns the user that owns this profile.
public function user()
{
    return $this->belongsTo(User::class);
}

}