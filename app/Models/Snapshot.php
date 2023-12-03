<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Snapshot extends Model
{
    use HasFactory;
    protected $table = 'snapshots';
    protected $fillable = [
        'simulation_id',
        'url',
        'name',
        'type',
    ];
    protected $hidden = ['created_at', 'updated_at'];
}
