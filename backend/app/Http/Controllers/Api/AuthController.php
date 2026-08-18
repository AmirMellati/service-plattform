<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Profile;
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

            'street' => ['required', 'string', 'max:255'],
            'house_number' => ['required', 'string', 'max:20'],
            'postal_code' => ['required', 'string', 'max:20'],
            'city' => ['required', 'string', 'max:255'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => $validated['password'],
            'role' => 'USER',
            'status' => 'AKTIV',
            'failed_login_attempts' => 0,
        ]);

        Profile::create([
            'user_id' => $user->id,
            'street' => $validated['street'],
            'house_number' => $validated['house_number'],
            'postal_code' => $validated['postal_code'],
            'city' => $validated['city'],
        ]);

        return response()->json([
            'message' => 'Benutzer erfolgreich registriert.',
            'user' => $user,
        ], 201);
    }


    public function login(Request $request): JsonResponse
    {
        // 1. Validate input.
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        // 2. Find user by email.
        $user = User::where('email', $validated['email'])->first();

        // 3. User does not exist.
        if (!$user) {
            return response()->json([
                'message' => 'E-Mail oder Passwort ist falsch.',
            ], 401);
        }

        // 4. Account is already blocked.
        if (strtoupper($user->status) === 'BLOCKED') {
            return response()->json([
                'message' => 'Ihr Konto ist gesperrt. Bitte kontaktieren Sie den Administrator.',
                'blocked' => true,
            ], 403);
        }

        // 5. Password is incorrect.
        if (!Hash::check($validated['password'], $user->password)) {

            // Increase failed login attempts.
            $user->increment('failed_login_attempts');

            // Reload fresh data from database.
            $user->refresh();

            // 6. Block account after 3 failed attempts.
            if ($user->failed_login_attempts >= 3) {

                $user->status = 'BLOCKED';
                $user->save();

                // Revoke all existing Sanctum tokens.
                $user->tokens()->delete();

                return response()->json([
                    'message' => 'Ihr Konto wurde nach 3 fehlgeschlagenen Anmeldeversuchen gesperrt. Bitte kontaktieren Sie den Administrator.',
                    'blocked' => true,
                    'failed_login_attempts' => $user->failed_login_attempts,
                    'remaining_attempts' => 0,
                ], 403);
            }

            $remainingAttempts = 3 - $user->failed_login_attempts;

            return response()->json([
                'message' => 'E-Mail oder Passwort ist falsch.',
                'blocked' => false,
                'failed_login_attempts' => $user->failed_login_attempts,
                'remaining_attempts' => $remainingAttempts,
            ], 401);
        }

        // 7. Password is correct.
        // Reset failed attempts after successful login.
        if ($user->failed_login_attempts > 0) {
            $user->failed_login_attempts = 0;
            $user->save();
        }

        // 8. Create Sanctum token.
        $token = $user->createToken('flutter-app')->plainTextToken;

        // 9. Login successful.
        return response()->json([
            'message' => 'Anmeldung erfolgreich.',
            'blocked' => false,
            'user' => $user,
            'token' => $token,
        ], 200);
    }
}