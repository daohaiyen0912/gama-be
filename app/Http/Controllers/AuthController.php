<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;


class AuthController extends Controller
{
    public function userinfo($id){
        $user = User::find($id);
        return $user;
    }
    public function update(Request $request, $id){
        $fields = $request->validate([
            'name' => 'string',
            'password' => 'string',
        ]);
        $user = User::find($id);
        if (isset($fields['name'])){
            $user->update([
                'name'=> $fields['name']
            ]);
        }
        if (isset($fields['password'])){
            $user->update([
                "password" => bcrypt($fields['password'])
            ]);
        }
        return $user;
    }
    public function register(Request $request)
    {
        try {
            $fields = $request->validate([
                'name' => 'required|string',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|confirmed',
            ]);
            $isExist = User::where('email', $fields['email'])->first();
            if (!$isExist) {
                $user =  User::create([
                    "name" => $fields['name'],
                    "email" => $fields['email'],
                    "password" => bcrypt($fields['password']),
                ]);
                $response = [
                    'success' => true,
                    'user' => $user
                ];
                return response($response, 200);
            } else {
                $response = [
                    'success' => false,
                    'message' => "Account already exists !!",
                ];
                return response($response, 400);
            }
        } catch (\Exception $e) {
            $response = [
                'success' => false,
                'message' => "Cannot regist new account!!",
            ];
            return response($response, 400);
        }
    }

//    public function update_user(Request $request, $id)
//    {
//        try {
//            $fields = $request->validate([
//                'permission' => 'required',
//                'start_at' => 'required|date',
//                'end_at' => 'nullable|date|after:start_at',
//                'is_active' => 'nullable',
//                'area' => 'required|string',
//            ]);
//            if ($fields['is_active'] == 0) {
//                User::where('permission', 'like', $fields['permission'] . "%")->update(['is_active' => $fields['is_active']]);
//            }
//            $user = User::where('permission', $id)->where('is_deleted', 0);
//            if ($user) {
////                if (isset($fields->password)) {
////                    $user->update(["password" => bcrypt($fields['password'])]);
////                }
//                $user->update([
//                    "name" => $fields['permission'],
//                    "permission" => $fields['permission'],
//                    "start_at" => $fields['start_at'],
//                    "end_at" => $fields['end_at'],
//                    "is_active" => $fields['is_active'],
//                    "area" => $fields['area'],
//                ]);
//                $response = [
//                    'success' => true,
//                    'user' => $user->get()
//                ];
//                return response($response, 200);
//            }
//        } catch (\Exception $e) {
//            $response = [
//                'success' => false,
//                'message' => "Cannot update user, please check the input again!!",
//            ];
//            return response($response, 200);
//        }
//    }



    public function login(Request $request)
    {
        try {
            $fields = $request->validate([
                'email' => 'required|string',
                'password' => 'required|string',
            ]);

            $user = User::where('email', $fields['email'])->first();

            if (!$user || !Hash::check($fields['password'], $user->password)) {
                return response([
                    'success' => false,
                    'message' => "user not found or password was wrong!!"
                ], 400);
            }

            $token = $user->createToken('myapptoken')->plainTextToken;
            $response = [
                'success' => true,
                'user' => $user,
                'token' => $token
            ];
            return response($response, 200);
        } catch (\Exception $e) {
            $response = [
                'success' => false,
                'message' => "User not found or password was wrong!!",
            ];
            return response($response, 400);
        }
    }

    public function logout(Request $request)
    {
        auth()->user()->tokens()->delete();
        return [
            'message' => 'logged out'
        ];
    }

}
