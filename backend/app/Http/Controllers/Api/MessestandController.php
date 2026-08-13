<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Messestand;
use Illuminate\Http\JsonResponse;

class MessestandController extends Controller
{
    public function index(): JsonResponse
    {
        $messestaende = Messestand::all();

        return response()->json($messestaende);
    }
}