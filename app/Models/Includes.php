<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Includes extends Model
{
    use HasFactory;
    protected $table = 'includes';
    protected $primaryKey = 'id';
    public $incrementing = false;
    protected $keyType = 'string';
    protected $fillable = [
        'id',
        'project_id',
        'filename',
    ];
    protected $hidden = ['created_at', 'updated_at'];
}
