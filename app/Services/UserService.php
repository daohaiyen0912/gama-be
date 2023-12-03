<?php

namespace App\Services;

use App\Models\User;

class UserService extends BaseService
{
    public function __construct()
    {
        parent::__construct();
        $this->model = User::class;
    }

    public function getUsers($params)
    {
        $users = $this->model::orderBy('created_at', 'desc');

        if(isset($params['over_view'])) {
            $user = $users->select('name', 'gavatar_num');
        }
    
        return $users->get();   
    }

}
