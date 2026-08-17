<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Messestand;
use Illuminate\Http\JsonResponse;
use App\Services\GeocodingService;

class MessestandController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // Start building the query to fetch Messestaende with their associated user and skills.
        $query = Messestand::with(['user', 'skills', 'einsatzgebiet']);
        // search for messestaende by skill if the 'skill' query parameter is provided
        if ($request->filled('skill')) {
            $skill = $request->query('skill');
            // Filters messestaende by skill name using a "like" query.
            $query->whereHas('skills', function ($q) use ($skill) {
                $q->where('name', 'like', '%' . $skill . '%');
            });
        }

        // Filters messestaende by service area.
        if ($request->filled('district')) {
            $district = $request->query('district');

            $query->whereHas('einsatzgebiet', function ($q) use ($district) {
                $q->where('district', 'like', '%' . $district . '%');
            });
        }

        // Filters messestaende by maximum starting price.
        if ($request->filled('max_price')) {
            $maxPrice = $request->query('max_price');

            $query->where('price_from', '<=', $maxPrice);
        }

        // Shows active featured messestaende first.
        $query->orderByRaw(
            'CASE
        WHEN featured = 1
        AND featured_until IS NOT NULL
        AND featured_until > NOW()
        THEN 0
        ELSE 1
    END'
        );

        // Newer messestaende are shown first within each group.
        $query->orderByDesc('created_at');

        $messestaende = $query->get();

        $messestaende = $query->get();

        return response()->json($messestaende);
    }

    // Returns the messestaende that belong to the authenticated user.
    public function mine(Request $request): JsonResponse
    {
        $messestaende = Messestand::with(['user', 'skills', 'einsatzgebiet'])
            ->where('user_id', $request->user()->id)
            ->get();

        return response()->json($messestaende);
    }

    // Creates a new messestand for the authenticated user.
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price_from' => ['nullable', 'numeric', 'min:0'],
            'price_to' => ['nullable', 'numeric', 'min:0'],

            'city' => ['required', 'string', 'max:255'],
            'district' => ['required', 'string', 'max:255'],

            'skill_ids' => ['required', 'array', 'min:1'],
            'skill_ids.*' => ['integer', 'exists:skills,id'],




        ]);

        // Creates the geocoding service.
        $geocodingService = app(GeocodingService::class);

        // Checks whether the entered service area really exists.
        $isValidServiceArea = $geocodingService->validateServiceArea(
            $validated['city'],
            $validated['district']
        );

        // Stops the request if the entered service area could not be validated.
        if (!$isValidServiceArea) {
            return response()->json([
                'message' => 'Das angegebene Einsatzgebiet wurde nicht gefunden.',
            ], 422);
        }





        // Creates the messestand and assigns it to the authenticated user.
        $messestand = Messestand::create([
            'user_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'price_from' => $validated['price_from'] ?? null,
            'price_to' => $validated['price_to'] ?? null,
            'featured' => false,




        ]);


        // Creates the service area for the new messestand.
// This represents where the handwerker offers the service,
// not the handwerker's private address.
        $messestand->einsatzgebiet()->create([
            'city' => $validated['city'],
            'district' => $validated['district'],
        ]);


        // Connects the selected skills to the new messestand.
        $messestand->skills()->sync($validated['skill_ids']);

        // Returns the newly created messestand with its user and skills.
        return response()->json(
            $messestand->load(['user', 'skills']),
            201
        );
    }

    // Deletes a messestand owned by the authenticated user.
    public function destroy(Request $request, Messestand $messestand): JsonResponse
    {
        // Checks whether the logged-in user owns this messestand.
        if ($messestand->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Du darfst diesen Messestand nicht löschen.',
            ], 403);
        }

        // Deletes the messestand.
        $messestand->delete();

        return response()->json([
            'message' => 'Messestand wurde erfolgreich gelöscht.',
        ]);
    }




    // Updates a messestand owned by the authenticated user.
    public function update(
        Request $request,
        Messestand $messestand
    ): JsonResponse {

        // Checks whether the logged-in user owns this messestand.
        if ($messestand->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Du darfst diesen Messestand nicht bearbeiten.',
            ], 403);
        }

        // Validates the updated messestand data.
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],

            'price_from' => ['nullable', 'numeric', 'min:0'],
            'price_to' => ['nullable', 'numeric', 'min:0'],

            'city' => ['required', 'string', 'max:255'],
            'district' => ['required', 'string', 'max:255'],

            'skill_ids' => ['required', 'array', 'min:1'],
            'skill_ids.*' => ['integer', 'exists:skills,id'],
        ]);

        // Creates the geocoding service.
        $geocodingService = app(GeocodingService::class);

        // Checks  the updated service area really exists.
        $isValidServiceArea = $geocodingService->validateServiceArea(
            $validated['city'],
            $validated['district']
        );

        // Stops the update if the service area is invalid.
        if (!$isValidServiceArea) {
            return response()->json([
                'message' => 'Das angegebene Einsatzgebiet wurde nicht gefunden.',
            ], 422);
        }

        // Updates the basic messestand information.
        $messestand->update([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'price_from' => $validated['price_from'] ?? null,
            'price_to' => $validated['price_to'] ?? null,
        ]);

        // Updates the service area of the messestand.
        $messestand->einsatzgebiet()->update([
            'city' => $validated['city'],
            'district' => $validated['district'],
        ]);

        // Updates the skills connected to the messestand.
        $messestand->skills()->sync(
            $validated['skill_ids']
        );

        // Returns the updated messestand with all related data.
        return response()->json(
            $messestand->load([
                'user',
                'skills',
                'einsatzgebiet',
            ])
        );
    }



    // Activates featured status for one month.
    public function activateFeatured(
        Request $request,
        Messestand $messestand
    ): JsonResponse {

        // Checks whether the logged-in user owns this messestand.
        if ($messestand->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Du darfst diesen Messestand nicht als Featured aktivieren.',
            ], 403);
        }

        // Activates featured status for one month.
        $messestand->update([
            'featured' => true,
            'featured_until' => now()->addMonth(),
        ]);

        // Returns the updated messestand.
        return response()->json([
            'message' => 'Featured wurde für einen Monat aktiviert.',
            'messestand' => $messestand,
        ]);
    }
}