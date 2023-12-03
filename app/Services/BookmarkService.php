<?php

namespace App\Services;

use App\Models\Bookmark;

class BookmarkService extends BaseService
{
    public function __construct()
    {
        parent::__construct();
        $this->model = Bookmark::class;
    }

    public function getBookmarks($params)
    {
        $bookmarks = $this->model::orderBy('created_at', 'desc');

        if(isset($params['created_by'])) {
            $bookmarks = $bookmarks->where('created_by', $params['created_by']);
        }

        if(isset($params['topic_id'])) {
            $bookmarks = $bookmarks->where('topic_id', $params['topic_id']);
        }

        return $bookmarks->get();
    }

}
