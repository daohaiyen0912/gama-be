<?php

namespace App\Services;

use App\Models\Research;

class ResearchService extends BaseService
{
    public function __construct()
    {
        parent::__construct();
        $this->model = Research::class;
    }

    public function getResearchs($params)
    {
        $researchs = $this->model::orderBy('created_at', 'desc');

        if(isset($params['created_by'])) {
            $researchs = $researchs->where('created_by', $params['created_by']);
        }

        if(isset($params['cate_id'])) {
            $researchs = $researchs->where('cate_id', $params['cate_id']);
        }

        return $researchs->get();   
    }

}
