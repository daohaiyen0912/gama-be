<?php

namespace App\Services;
use App\Models\Topic;

class BaseService
{
    protected $model;
    public function __construct()
    {
    }

    public function create(array $data)
    {
       return $this->model::create($data);
    }

    public function get()
    {
        return $this->model::all();
    }

    public function find($id)
    {
        return $this->model::find($id);
    }

    public function update($id, $data)
    {
        $topic = $this->model::find($id);
        
        return $topic->update($data);
    }

    public function delete($id)
    {
        $topic = $this->model::find($id);
        if ($topic) {
            $topic->delete();
        }
    }

}
