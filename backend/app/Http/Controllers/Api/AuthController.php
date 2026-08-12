<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => $validated['password'],
            'role' => 'USER',
            'status' => 'AKTIV',
        ]);

        return response()->json([
            'message' => 'Benutzer erfolgreich registriert.',
            'user' => $user,
        ], 201);
    }

    // Logs in a user by validating the email and password.
    public function login(Request $request): JsonResponse
    {
        // Validate the login data sent by the client.
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        // Find the user in the database by email address.
        $user = User::where('email', $validated['email'])->first();

        // Check if the user exists and if the entered password is correct.
        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'message' => 'E-Mail oder Passwort ist falsch.',
            ], 401);
        }

        // Create a Sanctum token for the authenticated user.
        $token = $user->createToken('flutter-app')->plainTextToken;

        // Return the authenticated user and token to the client.
        return response()->json([
            'message' => 'Anmeldung erfolgreich.',
            'user' => $user,
            'token' => $token,
        ], 200);
}
}