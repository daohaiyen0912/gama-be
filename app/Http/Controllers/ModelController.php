<?php

namespace App\Http\Controllers;

use App\Models\Includes;
use App\Models\Models;
use App\Models\Project;
use App\Models\Snapshot;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Storage;
use League\Flysystem\Filesystem;
use League\Flysystem\ZipArchive\ZipArchiveAdapter;

use phpseclib3\Net\SSH2;
use phpseclib3\Net\SFTP;

use Aws\S3\S3Client;

use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;

class ModelController extends Controller
{
    //
    public function simulate(Request $request)
    {
        $user_id = $request->user_id;
        $simulation_id = $request->simulation_id;
        $runnersReq = $request->runners;
        $number_of_simulation = $request->number_of_simulation;
        $model = Models::where('id', $simulation_id)->first();
        $project = Project::where("id", $model->project_id)->first();
        $xmlfile = file_get_contents($request->xmlfile);
        $data = [];
        //ghi đè xml từ request vào template run 
        $my_file = '../GAMA/headless/' . $user_id . '_template_run.xml';
        $handle = fopen($my_file, 'w');
        fwrite($handle, $xmlfile);
        fclose($handle);

        $s3 = new S3Client([
            'version'     => 'latest',
            'region'      => 'ap-southeast-2',
        ]);

        $bucket = 'gama-do-an';

        $resultDir = $simulation_id . '_outputHeadLess';

        $runners = explode(",", $runnersReq);
        $each_number_simu_of_runner = $number_of_simulation / count($runners);

        $remotepath = '/home/haiyen/Documents/opt/gama-platform/headless/samples/' . $user_id . '_template_run.xml';

        //Khởi tạo tiến trình
        $processes = [];
        $ssh = [];
        $commands = [];


        for ($i = 0; $i < count($runners); $i++) {
            $ssh[] = new SSH2($runners[$i]); // Thay 'remote_server' bằng địa chỉ máy chủ từ xa
            if (!$ssh[$i]->login('haiyen', 'haiyen')) { // Thay 'username' và 'password' bằng thông tin đăng nhập của bạn
                exit('Login Failed');
            }

            // Sử dụng phương thức put để tải lên tệp tin từ máy tính cục bộ lên máy chủ từ xa
            $sftp = new SFTP($runners[$i]);
            if (!$sftp->login('haiyen', 'haiyen')) {
                exit('Không thể đăng nhập vào SFTP');
            }
            $sftp->put($remotepath, $my_file, SFTP::SOURCE_LOCAL_FILE);

            $change_xml_final_step = 'cd /home/haiyen/Documents/opt/gama-platform/headless/samples && sed -i \'s/finalStep="' . $number_of_simulation . '"/finalStep="100"/\' ./' . $user_id . '_template_run.xml';
            $ssh[$i]->exec($change_xml_final_step);
        }

        // Tạo các lệnh sử dụng vòng lặp for
        for ($e = 0; $e < $each_number_simu_of_runner; $e++) {
            $gama_command = 'cd /home/haiyen/Documents/opt/gama-platform/headless/ && bash ./gama-headless.sh ./samples/' . $user_id . '_template_run.xml' . ' ./output/' . $simulation_id . '/index_' . ($e + 1);

            for ($i = 0; $i < count($runners); $i++) {
                $put_snapshot_command = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/' . $simulation_id . '/index_' . ($e + 1) . '/ && for file in snapshot/*; do
                    aws s3 cp "$file" s3://gama-do-an/' . $user_id . '/' . $runners[$i] . '/' . $simulation_id . '/index_' . ($e + 1) . '/
                done';
                $commands[] = $ssh[$i]->exec($gama_command . ' && ' . $put_snapshot_command);
            }
        }
        // Tạo một đối tượng Process cho mỗi runner
        $process = new Process($commands);

        // Bắt đầu tiến trình, nhưng không đợi cho đến khi kết thúc
        $process->start();

        // Lưu trữ các đối tượng Process
        $processes[] = $process;


        // Đợi cho tất cả các tiến trình hoàn thành
        $length = count($processes);
        for ($x = 0; $x < $length; $x++) {

            $processes[$x]->wait();

            // print_r($processes[$x]);

            if ($processes[$x]->isSuccessful()) {
                # Lấy tên file ảnh ra để lưu vào Snapshot
                $get_snapshot_name = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/' . $simulation_id . '/index_1/ && find ./snapshot/ -type f -exec basename {} \;';
                $output_put_s3 = $ssh[$x]->exec($get_snapshot_name);

                $array = explode("\n", $output_put_s3);

                Snapshot::where("simulation_id", $simulation_id)->delete();

                foreach ($array as $file_name) {
                    $url = $s3->getObjectUrl($bucket, "$user_id/$runners[$x]/$simulation_id/index_1/$file_name");

                    Snapshot::create([
                        'simulation_id' => $simulation_id,
                        'url' => urlencode($url),
                        'name' => $file_name,
                    ]);
                }

                $ssh[$x]->disconnect();
            } else {
                // #Lấy tên file ảnh ra để lưu vào Snapshot
                $get_snapshot_name = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/' . $simulation_id . '/index_1/ && find ./snapshot/ -type f -exec basename {} \;
                ';
                $output_put_s3 = $ssh[$x]->exec($get_snapshot_name);

                $array = explode("\n", $output_put_s3);

                Snapshot::where("simulation_id", $simulation_id)->delete();

                foreach ($array as $file_name) {
                    $url = $s3->getObjectUrl($bucket, "$user_id/$runners[$x]/$simulation_id/index_1/$file_name");

                    Snapshot::create([
                        'simulation_id' => $simulation_id,
                        'url' => urlencode($url),
                        'name' => $file_name,
                    ]);
                }

                // for ($i = 0; $i < $each_number_simu_of_runner; $i++) {
                //     $put_snapshot_command = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/index_' . ($i + 1) . '/ && for file in snapshot/*; do
                //         aws s3 cp "$file" s3://gama-do-an/' . $user_id . '/' . $runners[$x] . '/' . $simulation_id . '/index_' . ($i + 1) . '/
                //     done';

                //     $remove_snapshot_output = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/ && rm -rf ./index_' . ($i + 1);
                //     $ssh->exec($remove_snapshot_output);
                // }

                //     // $remove_xml_file = 'cd /home/haiyen/Documents/opt/gama-platform/headless/ && rm -rf ./samples/' . $user_id . '_template_run.xml';
                //     // $ssh->exec($remove_xml_file);

                // $ssh[$x]->disconnect();
                // }
            }
        }

        //Test th chạy ko nhiều máy
        // for ($i = 0; $i < $number_of_simulation; $i++) {
        //     //Đường dẫn đến thư mục trên máy B để lưu tệp

        //     $ssh = new SSH2($runners[0]); // Thay 'remote_server' bằng địa chỉ máy chủ từ xa
        //     if (!$ssh->login('haiyen', 'haiyen')) { // Thay 'username' và 'password' bằng thông tin đăng nhập của bạn
        //         exit('Login Failed');
        //     }

        //     // Sử dụng phương thức put để tải lên tệp tin từ máy tính cục bộ lên máy chủ từ xa
        //     $sftp = new SFTP($runners[0]);
        //     if (!$sftp->login('haiyen', 'haiyen')) {
        //         exit('Không thể đăng nhập vào SFTP');
        //     }
        //     $sftp->put($remotepath, $my_file, SFTP::SOURCE_LOCAL_FILE);
        //     // if ($sftp->put($remotepath, $my_file, SFTP::SOURCE_LOCAL_FILE)) {
        //     //     echo 'Upload successful';
        //     // } else {
        //     //     echo 'Upload failed';
        //     // }

        //     $change_xml_final_step = 'cd /home/haiyen/Documents/opt/gama-platform/headless/samples && sed -i \'s/finalStep="1"/finalStep="1000"/\' ./' . $user_id . '_template_run.xml';
        //     $ssh->exec($change_xml_final_step);

        //     # Lệnh thay đổi thư mục làm việc và chạy GAMA headless
        //     $gama_command = 'cd /home/haiyen/Documents/opt/gama-platform/headless/ && bash ./gama-headless.sh ./samples/' . $user_id . '_template_run.xml' . ' ./output/' . $simulation_id . '/index_' . ($i + 1);

        //     $ssh->exec($gama_command);
        //     // echo "Kết quả tạo file xml:\n";
        //     // echo $output_initial_2;

        //     # Lệnh put tất cả ảnh trong snapshot vừa rồi lên s3
        //     $put_snapshot_command = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/' . $simulation_id . '/index_' . ($i + 1) . '/ && for file in snapshot/*; do
        //     aws s3 cp "$file" s3://gama-do-an/' . $user_id . '/' . $runners[0] . '/' . $simulation_id . '/index_' . ($i + 1) . '/
        // done';

        //     $ssh->exec($put_snapshot_command);

        //     # Lấy tên file ảnh ra để lưu vào Snapshot
        //     $get_snapshot_name = 'cd /home/haiyen/Documents/opt/gama-platform/headless/output/' . $simulation_id . '/index_1/ && find ./snapshot/ -type f -exec basename {} \;
        //     ';
        //     $output_put_s3 = $ssh->exec($get_snapshot_name);
        //     // echo "Kết quả tạo đẩy snapshot:\n";

        //     $array = explode("\n", $output_put_s3);

        //     Snapshot::where("simulation_id", $simulation_id)->delete();

        //     foreach ($array as $file_name) {
        //         $url = $s3->getObjectUrl($bucket, "$user_id/$runners[0]/$simulation_id/index_1/$file_name");

        //         Snapshot::create([
        //             'simulation_id' => $simulation_id,
        //             'url' => urlencode($url),
        //             'name' => $file_name,
        //         ]);
        //     }

        //     $ssh->disconnect();
        // }

        $output_names = Snapshot::where('simulation_id', $simulation_id)->distinct()->pluck('name');
        foreach ($output_names as $output_name) {
            //data respose
            $urls = Snapshot::where('simulation_id', $simulation_id)->where('name', $output_name)->pluck('url');;
            array_push($data, (object)[
                'name' => $output_name,
                'urls' => $urls
            ]);
        }
        $outputdir = "../GAMA/headless/" . $simulation_id . '_outputHeadLess/simulation-outputs' . $simulation_id . '.xml';
        try {
            $file = File::get($outputdir);
            $outputxml = Response::make($file, 200);
        } catch (\Exception $e) {
            $outputxml = null;
        }
        $response = [
            'success' => true,
            'data' => $data,
            'ouputxml' => $outputxml
        ];

        return response($response, 200)->header('Access-Control-Allow-Origin', '*');

        //a Nam
        // run command headless
        $command = 'cd ../GAMA/headless;bash ./gama-headless.sh ' . $user_id . '_template_run.xml ' . $resultDir;
        exec($command . ' 2>&1', $output, $retval);
        //get image after run headless 
        $dir = '/var/www/GAMA/headless/' . $simulation_id . '_outputHeadLess/snapshot/*';
        //không có ảnh thì return 400
        if (glob($dir)) {
            Snapshot::where("simulation_id", $simulation_id)->delete();
            Storage::disk('s3')->delete('snapshots/' . $simulation_id);
            $list = glob($dir);
            natsort($list);
            foreach ($list as $file) {
                //put từng ảnh lên s3 đồng thời tạo bản ghi snapshot
                $file_name = str_replace('/var/www/GAMA/headless/' . $simulation_id . '_outputHeadLess/snapshot/', '', $file);
                $url = Storage::disk('s3')->put('snapshots/' . $simulation_id, $file, $file_name);
                $url = Storage::disk('s3')->get($url);
                $file_name = substr($file_name, 0, strpos($file_name, $simulation_id));
                Snapshot::create([
                    'simulation_id' => $simulation_id,
                    'url' => $url,
                    'name' => $file_name,
                ]);
            }
            $output_names = Snapshot::where('simulation_id', $simulation_id)->distinct()->pluck('name');
            foreach ($output_names as $output_name) {
                //data respose
                $urls = Snapshot::where('simulation_id', $simulation_id)->where('name', $output_name)->pluck('url');;
                array_push($data, (object)[
                    'name' => $output_name,
                    'urls' => $urls
                ]);
            }
            $outputdir = "../GAMA/headless/" . $simulation_id . '_outputHeadLess/simulation-outputs' . $simulation_id . '.xml';
            try {
                $file = File::get($outputdir);
                $outputxml = Response::make($file, 200);
            } catch (\Exception $e) {
                $outputxml = null;
            }
            $response = [
                'success' => true,
                'data' => $data,
                'ouputxml' => $outputxml
            ];
        } else {
            $response = [
                'success' => false,
                'output' => $output,
                'command' => $command,
                'message' => "Something went wrong! Please contact admin!"
            ];
            return response($response, 400);
        }
        $dir = "../GAMA/headless/userProjects/" . $request->user_id;
        $modelsDir = $dir . '/' . $project->name . '/models/';
        $includesDir = $dir . '/' . $project->name . '/includes/';
        $scanned_models = S3Controller::getDirContents($modelsDir);
        $scanned_includes = S3Controller::getDirContents($includesDir);
        foreach ($scanned_models as $model) {
            $isExist = Models::where('filename', $model)->first();
            if (!$isExist) {
                Models::create([
                    "id" => uniqid(),
                    "project_id" => $project->id,
                    "filename" => $model
                ]);
            }
        }

        foreach ($scanned_includes as $include) {
            $isExist = Includes::where('filename', $include)->first();
            if (!$isExist) {
                Includes::create([
                    "id" => uniqid(),
                    "project_id" => $project->id,
                    "filename" => $include
                ]);
            }
        }


        exec('cd ../GAMA/headless; rm -rf .work*', $output, $retval);
        exec('cd ../GAMA/headless; rm -rf ' . $simulation_id . '_outputHeadLess/snapshot', $output, $retval);
        return response($response, 200)->header('Access-Control-Allow-Origin', '*');
    }

    public function simulateLatest($id)
    {

        $output_names = Snapshot::where('simulation_id', $id)->distinct()->pluck('name');
        $data = [];
        foreach ($output_names as $output_name) {
            $urls = Snapshot::where('simulation_id', $id)->where('name', $output_name)->pluck('url');;
            array_push($data, (object)[
                'name' => $output_name,
                'urls' => $urls
            ]);
        }
        $outputdir = "../GAMA/headless/" . $id . '_outputHeadLess/simulation-outputs' . $id . '.xml';
        try {
            $file = File::get($outputdir);
            $outputxml = Response::make($file, 200);
        } catch (\Exception $e) {
            $outputxml = null;
        }
        $response = [
            'success' => true,
            'data' => $data,
            'ouputxml' => $outputxml
        ];
        return response($response, 200);
    }

    public function buildContentFile($urls, $fps)
    {
        $content = '';
        foreach ($urls as $url) {
            $row1 = "file '" . $url . "'\n";
            $row2 = "duration " . $fps . "\n";
            $content = $content . $row1 . $row2;
        }
        return $content;
    }

    //api lấy ảnh để show
    public function simulateDownload($id, Request $request)
    {
        $fps = $request->fps;
        File::delete(File::glob(public_path('*.zip')));
        $output_names = Snapshot::where('simulation_id', $id)->distinct()->pluck('name');
        $resultDir = "../GAMA/headless/" . $id . '_outputHeadLess/';
        $source_disk = 's3';
        $source_path = '/download/' . $id;
        $zip_file_name = $id . '.zip';
        Storage::disk('s3')->delete($source_path);

        //tải file ảnh từ s3 về
        foreach ($output_names as $output_name) {
            $urls = Snapshot::where('simulation_id', $id)->where('name', $output_name)->pluck('url');
            print_r($urls);
            $resultTextFile = $resultDir . $output_name . "_output.txt";
            $resultMp4File = $resultDir . $output_name . ".mp4";
            $fileContent = $this->buildContentFile($urls, $fps);
            file_put_contents($resultTextFile, $fileContent);
            $ffmpeg = \FFMpeg\FFMpeg::create();
            $video = $ffmpeg->open($resultTextFile);
            $video->save(new \FFMpeg\Format\Video\X264(), $resultMp4File);
            Storage::disk('s3')->put('download/' . $id, $resultMp4File, $output_name . '.mp4');
            // $url = Storage::disk('s3')->getObjUrl($url);
        }
        exec('cd ' . $resultDir . '; rm -rf *.mp4', $output, $retval);

        $file_names = Storage::disk($source_disk)->files($source_path);
        print_r($file_names);
        $zip = new Filesystem(new ZipArchiveAdapter(public_path($zip_file_name)));
        foreach ($file_names as $file_name) {
            $file_content = Storage::disk($source_disk)->get($file_name);
            $zip->put($file_name, $file_content);
        }

        // $zip->getAdapter()->getArchive()->close();
        return response()->download(public_path($zip_file_name));
    }

    //     public function simulateDownload($id, Request $request)
    // {
    //     $fps = $request->fps;
    //     $output_names = Snapshot::where('simulation_id', $id)->distinct()->pluck('name');
    //     $resultDir = "../GAMA/headless/{$id}_outputHeadLess";
    //     $source_disk = 's3';
    //     $source_path = "/download/{$id}";
    //     $zip_file_name = "{$id}.zip";

    //     // Tạo thư mục nếu nó không tồn tại
    //     if (!File::exists($resultDir)) {
    //         File::makeDirectory($resultDir, 0755, true, true);
    //     }

    //     // Xóa tất cả các tệp tạm thời trước đó
    //     File::cleanDirectory($resultDir);

    //     // Tải file ảnh từ S3 và tạo file mp4
    //     foreach ($output_names as $output_name) {
    //         $urls = Snapshot::where('simulation_id', $id)->where('name', $output_name)->pluck('url');
    //         $resultTextFile = "{$resultDir}/{$output_name}_output.txt";
    //         $resultMp4File = "{$resultDir}/{$output_name}.mp4";
    //         $fileContent = $this->buildContentFile($urls, $fps);
    //         file_put_contents($resultTextFile, $fileContent);

    //         // Sử dụng thư viện PHP-FFMpeg để tạo video
    //         // Cần cài đặt thư viện trước: composer require pbmedia/laravel-ffmpeg
    //         $ffmpeg = \FFMpeg\FFMpeg::create();
    //         $video = $ffmpeg->open($resultTextFile);
    //         $video->save(new \FFMpeg\Format\Video\X264(), $resultMp4File);
    //     }

    //     // Gửi tất cả các tệp MP4 lên S3
    //     foreach ($output_names as $output_name) {
    //         $resultMp4File = "{$resultDir}/{$output_name}.mp4";
    //         Storage::disk('s3')->put("{$source_path}/{$output_name}.mp4", file_get_contents($resultMp4File));
    //     }

    //     // Tạo và trả về tệp ZIP
    //     $zip = new Filesystem(new ZipArchiveAdapter(storage_path("app/public/{$zip_file_name}")));
    //     $file_names = Storage::disk($source_disk)->files($source_path);

    //     foreach ($file_names as $file_name) {
    //         $file_content = Storage::disk($source_disk)->get($file_name);
    //         $zip->put($file_name, $file_content);
    //     }

    //     return response()->download(storage_path("app/public/{$zip_file_name}"));
    // }
}
