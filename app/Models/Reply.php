<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reply extends Model
{
    use HasFactory;

    protected $fillable = ['content', 'topic_id', 'created_by'];


    public function users()
    {
        return $this->belongsTo(User::class, 'created_by', 'id');
    }
}
