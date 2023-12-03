<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Research extends Model
{
    use HasFactory;
    
    protected $table = 'research';

    protected $fillable = ['content', 'name', 'created_by', 'cate_id'];
}
