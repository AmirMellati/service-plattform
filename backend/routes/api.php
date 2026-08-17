<?php


use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HealthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MessestandController;
use App\Models\Skill;



Route::get('/health', HealthController::class);
Route::post('/register', [AuthController::class, 'register']);
// Handles user login requests.
Route::post('/login', [AuthController::class, 'login']);
Route::get('/messestaende', [MessestandController::class, 'index']);


/* Protects the route with Sanctum and returns only
 the authenticated user's messestaende.*/
Route::middleware('auth:sanctum')->get(
    '/me/messestaende',
    [MessestandController::class, 'mine']
);

// Creates a new messestand for the authenticated user.
Route::middleware('auth:sanctum')->post(
    '/messestaende',
    [MessestandController::class, 'store']
);

// Returns all available skills for messestand selection.
Route::get('/skills', function () {
    return Skill::orderBy('name')->get();
});

// Deletes a messestand that belongs to the authenticated user.
Route::delete(
    '/messestaende/{messestand}',
    [MessestandController::class, 'destroy']
)->middleware('auth:sanctum');


// Updates a messestand that belongs to the authenticated user.
Route::put(
    '/messestaende/{messestand}',
    [MessestandController::class, 'update']
)->middleware('auth:sanctum');

// Activates the featured status of a messestand that belongs to the authenticated user.
Route::post(
    '/messestaende/{messestand}/featured',
    [MessestandController::class, 'activateFeatured']
)->middleware('auth:sanctum');