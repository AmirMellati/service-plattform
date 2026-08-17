<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Messestand;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessestandBildController extends Controller
{
    // Uploads one image for a messestand.
    public function store(
        Request $request,
        Messestand $messestand
    ): JsonResponse {
        // Only the owner of the messestand may upload an image.
        if ($messestand->user_id !== $request->user()->id) {
            return response()->json([
                'message' =>
                    'Du darfst diesem Messestand kein Bild hinzufügen.',
            ], 403);
        }

        // Validates the uploaded file.
        $request->validate([
            'bild' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
        ], [
            'bild.required' =>
                'Bitte wähle ein Bild aus.',

            'bild.image' =>
                'Die hochgeladene Datei muss ein Bild sein.',

            'bild.mimes' =>
                'Das Bild muss vom Typ JPG, JPEG, PNG oder WEBP sein.',

            'bild.max' =>
                'Das Bild darf maximal 5 MB groß sein.',
        ]);

        // Stores the real image file inside:
        // storage/app/public/messestaende/{messestand_id}
        $path = $request->file('bild')->store(
            'messestaende/' . $messestand->id,
            'public'
        );

        // Creates a new database row in messestand_bilder.
        // messestand_id is automatically added through the relationship.
        $bild = $messestand->bilder()->create([
            'bild' => $path,
        ]);

        // Returns information about the uploaded image.
        return response()->json([
            'message' =>
                'Bild wurde erfolgreich hochgeladen.',

            'bild' => $bild,

            'url' => asset(
                'storage/' . $path
            ),
        ], 201);
    }
}