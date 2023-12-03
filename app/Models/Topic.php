<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Topic extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'cate_id',
        'created_by',
        'status'
    ];

    // public function users()
    // {
    //     return $this->belongsToMany(User::class, 'bookmarks', 'topic_id', 'created_by');
    // }
 
    public function bookmarks()
    {
        return $this->hasMany(Bookmark::class, 'topic_id', 'id');
    }
}
