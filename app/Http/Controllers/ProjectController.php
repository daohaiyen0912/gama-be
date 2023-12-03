<?php

namespace App\Http\Controllers;

use App\Models\Includes;
use App\Models\Models;
use Illuminate\Http\Request;
use App\Models\Project;

class ProjectController extends Controller
{
    public function delete(Request $request){
        $user_id = $request->user_id;
        $project_id = $request->project_id;
        Models::where("project_id", $project_id)->delete();
        Includes::where("project_id", $project_id)->delete();
        $project = Project::where('id', $project_id)->first();
        exec('cd ../GAMA/headless/userProjects/'.$user_id.'; rm -rf '. $project->name , $output, $retval);
        $project->delete();
        $response = [
            'success' => true
        ];
        return response($response, 200);
    }

    public function list(Request $request){
        try {
            $request->validate([
                'user_id' => 'required',
                'project_name' => 'nullable',
            ]);
            $projects = Project::orderBy('id');
            $projects =  $projects->where('user_id', $request->user_id);

            if(isset($request->project_name)){
                $projects =  $projects->where('name', "LIKE" , "%". $request->project_name."%");
            }
            $projects = $projects->get();
            $data = [];
            foreach ($projects as $project){
                $models = Models::select('id','filename')->where("project_id", $project->id)->orderBy("filename")->get();
                $includes = Includes::select('id','filename')->where("project_id", $project->id)->orderBy("filename")->get();
                $project->models = $models;
                $project->includes = $includes;
               array_push($data, $project);
            }

            $response = [
                'success' => true,
                'data' => $data
            ];
            return response($response, 200);
        } catch (\Exception $e) {
            return response([
                'success' => false,
                'message' => "cannot get projects !!"
            ], 400);
        }
    }


}
