<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Messestand;
use Illuminate\Http\JsonResponse;

class MessestandController extends Controller
{
    public function index(Request $request): JsonResponse
{
    // Start building the query to fetch Messestaende with their associated user and skills.
    $query = Messestand::with(['user', 'skills']);
// search for messestaende by skill if the 'skill' query parameter is provided
    if ($request->filled('skill')) {
        $skill = $request->query('skill');

        $query->whereHas('skills', function ($q) use ($skill) {
            $q->where('name', 'like', '%' . $skill . '%');
        });
    }

    $messestaende = $query->get();

    return response()->json($messestaende);
}
}