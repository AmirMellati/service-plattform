<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Einsatzgebiet extends Model
{
    // The database table used by this model.
    protected $table = 'einsatzgebiete';

    
    // Fields that can be mass assigned.
    protected $fillable = [
        'messestand_id',
        'city',
        'district',
    ];

    // Each einsatzgebiet belongs to one messestand.
    public function messestand()
    {
        return $this->belongsTo(Messestand::class);
    }

}