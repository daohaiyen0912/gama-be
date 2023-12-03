<?php

namespace App\Services;

use App\Models\Topic;

class ForumService extends BaseService
{
    public function __construct()
    {
        parent::__construct();
        $this->model = Topic::class;
    }

    public function getTopics($params)
    {
        $topics = $this->model::orderBy('created_at', 'desc');

        if(isset($params['status'])) {
            $topics = $topics->where('status', $params['status']);
        }

        if(isset($params['created_by'])) {
            $topics = $topics->where('created_by', $params['created_by']);
        }

        if(isset($params['bookmarked']) && isset($params['user_id']) && $params['bookmarked']) {
            $userId = $params['user_id'];
            $topics = $topics->whereHas('bookmarks', function ($query) use ($userId) {
                $query->where('created_by', $userId);
            });
        }

        if(isset($params['cate_id'])) {
            $topics = $topics->where('cate_id', $params['cate_id']);
        }

        return $topics->get();
    }

}
