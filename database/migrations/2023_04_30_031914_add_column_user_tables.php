<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddColumnUserTables extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->integer('gavatar_num')->nullable();
            $table->integer('role')->nullable();
            $table->integer('gender')->nullable();
            $table->string('phone_number')->nullable();
            $table->string('nationality')->nullable();
            $table->string('address')->nullable();
            $table->date('birthday')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('users', function($table) {
            $table->dropColumn('gavatar_num');
            $table->dropColumn('role');
            $table->dropColumn('gender');
            $table->dropColumn('phone_number');
            $table->dropColumn('nationality');
            $table->dropColumn('address');
            $table->dropColumn('birthday');
        });
    }
}
