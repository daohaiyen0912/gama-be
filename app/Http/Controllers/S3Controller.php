<?php

namespace App\Http\Controllers;

use App\Models\Includes;
use App\Models\Models;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\In;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use ZipArchive;

class S3Controller extends Controller
{
    public $zipExt = ['zip'];
    public $readableFile = ['gaml', 'csv', 'png', 'jpg', 'jpeg'];

    function getDirContents($path)
    {

        $rii = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($path));

        $files = array();
        foreach ($rii as $file)
            if (!$file->isDir())
                if ($file->getPathname()) {
                    $filename = str_replace($path, '', $file->getPathname());
                    if ($filename[0] != '.')
                        $files[] = str_replace($path, '', $file->getPathname());
                }
        return $files;
    }

    public function uploadFile(Request $request)
    {
        $request->validate([
            'payload' => 'required',
            "user_id" => 'required'
        ]);


        $file = $request->payload->getClientOriginalName();

        $path_parts = pathinfo($file);
        $extension = $path_parts['extension'];
        $fileName = $path_parts['filename'];


        if (in_array($extension, $this->zipExt)) {
            $isExist = Project::where("user_id", $request->user_id)->where("name", $fileName);

            $zip = new ZipArchive;
            $dir = "../GAMA/headless/userProjects/" . $request->user_id;
            $res = $zip->open($request->payload);
            if ($res === TRUE) {
                $zip->extractTo($dir);
                $zip->close();
            }
            exec('cd ' . $dir . "; rm -rf __*", $output, $retval);
            if (!$isExist->count()) {
                $project = Project::create([
                    'user_id' => $request->user_id,
                    "name" => $fileName,
                ]);
            } else {
                $project = $isExist->first();
                Models::where("project_id", $project->id)->delete();
                Includes::where("project_id", $project->id)->delete();
            }

            $dir = "../GAMA/headless/userProjects/" . $request->user_id;
            $modelsDir = $dir . '/' . $fileName . '/models/';
            $includesDir = $dir . '/' . $fileName . '/includes/';
            $scanned_models = $this->getDirContents($modelsDir);
            $scanned_includes = $this->getDirContents($includesDir);
            foreach ($scanned_models as $model) {
                Models::create([
                    "id" => uniqid(),
                    "project_id" => $project->id,
                    "filename" => $model
                ]);
            }
            foreach ($scanned_includes as $include) {
                Includes::create([
                    "id" => uniqid(),
                    "project_id" => $project->id,
                    "filename" => $include
                ]);
            }
            $response = [
                'success' => true
            ];
            return response($response, 200);
        } else {
            $response = [
                'success' => false,
                'message' => "only zip files are supported"
            ];
            return response($response, 400);
        }
    }

    public function uploadSingleFile(Request $request)
    {
        $request->validate([
            'payload' => 'required',
            "user_id" => 'required'
        ]);


        $file = $request->payload->getClientOriginalName();

        $path_parts = pathinfo($file);
        $extension = $path_parts['extension'];
        $fileName = $path_parts['filename'];


        if (in_array($extension, $this->zipExt)) {
            $isExist = Project::where("user_id", $request->user_id)->where("name", $fileName);

            $zip = new ZipArchive;
            $dir = "../GAMA/headless/userProjects/" . $request->user_id;
            $res = $zip->open($request->payload);
            if ($res === TRUE) {
                $zip->extractTo($dir);
                $zip->close();
            }
            exec('cd ' . $dir . "; rm -rf __*", $output, $retval);
            if (!$isExist->count()) {
                $project = Project::create([
                    'user_id' => $request->user_id,
                    "name" => $fileName,
                ]);
            } else {
                $project = $isExist->first();
                Models::where("project_id", $project->id)->delete();
                Includes::where("project_id", $project->id)->delete();
            }

            $dir = "../GAMA/headless/userProjects/" . $request->user_id;
            $modelsDir = $dir . '/' . $fileName . '/models/';
            $includesDir = $dir . '/' . $fileName . '/includes/';
            $scanned_models = $this->getDirContents($modelsDir);
            $scanned_includes = $this->getDirContents($includesDir);
            foreach ($scanned_models as $model) {
                Models::create([
                    "id" => uniqid(),
                    "project_id" => $project->id,
                    "filename" => $model
                ]);
            }
            foreach ($scanned_includes as $include) {
                Includes::create([
                    "id" => uniqid(),
                    "project_id" => $project->id,
                    "filename" => $include
                ]);
            }
            $response = [
                'success' => true
            ];
            return response($response, 200);
        } else {
            $response = [
                'success' => false,
                'message' => "only zip files are supported"
            ];
            return response($response, 400);
        }
    }

    public function readFile(Request $request)
    {
        try {
            $request->validate([
                'path' => 'required',
                "user_id" => 'required'
            ]);
            $path_parts = pathinfo($request->path);
            $extension = $path_parts['extension'];
            $dir = "../GAMA/headless/userProjects/" . $request->user_id . '/' . $request->path;
            if (in_array($extension, $this->readableFile)) {
                return response()->file($dir);
            } else {
                $response = [
                    'success' => false,
                    'message' => "this file is not supported to read"
                ];
                return response($response, 400);
            }
        } catch (\Exception $e) {
            $response = [
                'success' => false,
                'message' => "this file was not found"
            ];
            return response($response, 400);
        }
    }

    public function listFile(Request $request)
    {
        try {
            $request->validate([
                'ids' => 'required',
                'user_id' => 'required'
            ]);
            $ids = $request->ids;
            $user_id = $request->user_id;
            $includeFiles = Includes::join('projects', 'includes.project_id', '=', 'projects.id')
                ->whereIn('includes.id', $ids)
                ->select('includes.id', 'projects.name', 'includes.filename')->get();
            $modelFiles = Models::join('projects', 'models.project_id', '=', 'projects.id')
                ->whereIn('models.id', $ids)
                ->select('models.id', 'projects.name', 'models.filename')->get();
            $files = [];

            foreach ($includeFiles as $includeFile) {
                $dir = "../GAMA/headless/userProjects/" . $user_id . '/' . $includeFile->name . '/includes/' . $includeFile->filename;
                $file = File::get($dir);
                $obj = (object)array(
                    'id' => $includeFile->id,
                    'file' => $file
                );
                array_push($files, $obj);
            }
            foreach ($modelFiles as $modelFile) {
                $dir = "../GAMA/headless/userProjects/" . $user_id . '/' . $modelFile->name . '/models/' . $modelFile->filename;
                $file = File::get($dir);
                $obj = (object)array(
                    'id' => $modelFile->id,
                    'file' => $file
                );
                array_push($files, $obj);
            }
            $response = [
                'success' => true,
                'files' => $files
            ];
            return response($response, 200);

        } catch (\Exception $e) {
            $response = [
                'success' => false,
                'message' => "this file was not found"
            ];
            return response($response, 400);
        }
    }

    public function updateFile(Request $request)
    {
        try {
            $request->validate([
                'path' => 'required',
                "user_id" => 'required',
                "file" => 'required'
            ]);
            $path_parts = pathinfo($request->path);
            $extension = $path_parts['extension'];
            if (in_array($extension, $this->readableFile)) {
                $dir = "../GAMA/headless/userProjects/" . $request->user_id . '/' . $request->path;
                file_put_contents($dir, file_get_contents($request->file));
                return response()->file($dir);
            } else {
                $response = [
                    'success' => false,
                    'message' => "cannot update this file"
                ];
                return response($response, 400);
            }
        } catch (\Exception $e) {
            $response = [
                'success' => false,
                'message' => "this file was not found"
            ];
            return response($response, 400);
        }
    }

    public function createFile(Request $request)
    {
        try {
            $request->validate([
                "path" => 'required',
                "type" => 'required',
                "project_id" => 'required',
                "user_id" => 'required',
                "file" => 'required'
            ]);
            $type = $request->type;
            $path = $request->path;
            $project_id = $request->project_id;
            $project_name = Project::findOrFail($project_id)->name;

            $fileDir = $request->user_id . '/' . $project_name . '/' . $type . '/' . $path;
            $dir = "../GAMA/headless/userProjects/" . $fileDir;

            Storage::disk('GAMA')->put($fileDir, file_get_contents($request->file));
            if ($type == "models") {
                Models::create([
                    "id" => uniqid(),
                    "project_id" => $project_id,
                    "filename" => $path
                ]);
            } elseif ($type == "includes") {
                Includes::create([
                    "id" => uniqid(),
                    "project_id" => $project_id,
                    "filename" => $path
                ]);
            }
            return response()->file($dir);
        } catch (\Exception $e) {
            $response = [
                'success' => false,
                'message' => "this file was not found"
            ];
            return response($response, 400);
        }
    }

    public function deleteFile($id){
        $model = Models::where('id',$id)->first();
        $include = Includes::where('id',$id)->first();
        if ($model) {
            $project = Project::find($model->project_id);
            $path = $project->user_id . '/' . $project->name . '/models/' . $model->filename;
            Storage::disk('GAMA')->delete($path);
            $model->delete();

        } elseif ($include) {
            $project = Project::find($include->project_id);
            $path = $project->user_id . '/' . $project->name . '/includes/' . $include->filename;
            Storage::disk('GAMA')->delete($path);
            $include->delete();
        }
    }
}
