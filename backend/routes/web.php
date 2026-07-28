<?php

use App\Http\Controllers\AdminSsoController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// 小程序 JWT 免登录进后台（绕过 web-view 里不稳定的 Livewire 登录表单）
Route::get('/admin/sso', AdminSsoController::class);
