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

    // Returns the messestaende that belong to the authenticated user.
    public function mine(Request $request): JsonResponse
    {
        $messestaende = Messestand::with(['user', 'skills'])
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

            'street' => ['required', 'string', 'max:255'],
            'house_number' => ['required', 'string', 'max:20'],
            'postal_code' => ['required', 'string', 'max:20'],
            'city' => ['required', 'string', 'max:255'],

            'skill_ids' => ['required', 'array', 'min:1'],
            'skill_ids.*' => ['integer', 'exists:skills,id'],
        ]);



        // Creates the messestand and assigns it to the authenticated user.
        $messestand = Messestand::create([
            'user_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'price_from' => $validated['price_from'] ?? null,
            'price_to' => $validated['price_to'] ?? null,
            'featured' => false,




        ]);

        // Creates the address for the new messestand.
        $messestand->einsatzgebiet()->create([
            'street' => $validated['street'],
            'house_number' => $validated['house_number'],
            'postal_code' => $validated['postal_code'],
            'city' => $validated['city'],
        ]);


        // Connects the selected skills to the new messestand.
        $messestand->skills()->sync($validated['skill_ids']);

        // Returns the newly created messestand with its user and skills.
        return response()->json(
            $messestand->load(['user', 'skills']),
            201
        );
    }

}