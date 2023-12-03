<?php

namespace App\Services;

use App\Models\Reply;

class ReplyService extends BaseService
{
    public function __construct()
    {
        parent::__construct();
        $this->model = Reply::class;
    }

    public function getReplies($params)
    {
        $replies = $this->model::orderBy('created_at', 'desc');

        if(isset($params['created_by'])) {
            $replies = $replies->where('created_by', $params['created_by']);
        }

        if(isset($params['topic_id'])) {
            $replies = $replies->where('topic_id', $params['topic_id']);
        }

        return $replies->get();   
    }

}
