<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class GeocodingService
{
    // Converts a normal address into geographic data using Nominatim.
    public function geocode(
        string $street,
        string $houseNumber,
        string $postalCode,
        string $city
    ): ?array {

        // Sends the address to the Nominatim geocoding API.
        $response = Http::withHeaders([
            // Nominatim requires a meaningful User-Agent header.
            'User-Agent' => 'Comgatus-Project/1.0',
        ])->get('https://nominatim.openstreetmap.org/search', [

                    // Combines house number and street for the search request.
                    'street' => $houseNumber . ' ' . $street,

                    // Postal code entered by the user.
                    'postalcode' => $postalCode,

                    // City entered by the user.
                    'city' => $city,

                    // Restricts search results to Germany.
                    'countrycodes' => 'de',

                    // Requests the result as JSON.
                    'format' => 'jsonv2',

                    // Requests detailed address information such as borough or suburb.
                    'addressdetails' => 1,

                    // We only need the best matching result.
                    'limit' => 1,
                ]);

        // If the external API request failed, stop and return null.
        if ($response->failed()) {
            return null;
        }

        // Converts the JSON response into a PHP array.
        $results = $response->json();

        // If Nominatim found no matching address, return null.
        if (empty($results)) {
            return null;
        }

        // Takes the first and best matching result.
        $result = $results[0];

        // Reads the detailed address information.
        // If "address" does not exist, use an empty array.
        $address = $result['address'] ?? [];

        // Returns only the geographic information needed by our application.
        return [

            // Exact latitude of the address.
            'latitude' => $result['lat'] ?? null,

            // Exact longitude of the address.
            'longitude' => $result['lon'] ?? null,

            // Tries different OpenStreetMap fields to find the district.
            // Example: Hamburg -> Altona.
            'district' => $address['borough']
                ?? $address['city_district']
                ?? $address['suburb']
                ?? null,
        ];
    }


    // Checks whether a city and service area exist in Germany.
    public function validateServiceArea(
        string $city,
        string $district
    ): bool {
        // Searches for the entered district together with the city.
        $response = Http::withHeaders([
            // Nominatim requires an identifiable User-Agent.
            'User-Agent' => 'Comgatus-Project/1.0',
        ])->get('https://nominatim.openstreetmap.org/search', [
                    // Free-form location search, for example "Altona, Hamburg".
                    'q' => $district . ', ' . $city,

                    // Restricts the search to Germany.
                    'countrycodes' => 'de',

                    // Requests JSON output.
                    'format' => 'jsonv2',

                    // Address details help us inspect the returned city/district.
                    'addressdetails' => 1,

                    // One matching result is enough for this validation.
                    'limit' => 1,
                ]);

        // If the external service could not be reached,
        // the location cannot currently be validated.
        if ($response->failed()) {
            return false;
        }

        // Converts the JSON response into a PHP array.
        $results = $response->json();

        // No result means the entered service area was not found.
        if (empty($results)) {
            return false;
        }

        $address = $results[0]['address'] ?? [];

        // Reads the city returned by Nominatim.
        $returnedCity = $address['city']
            ?? $address['town']
            ?? $address['municipality']
            ?? null;

        // Reads the district/area returned by Nominatim.
        $returnedDistrict = $address['city_district']
            ?? $address['suburb']
            ?? $address['borough']
            ?? $address['quarter']
            ?? null;

        // Checks whether the returned city and district match the user input.
        return $returnedCity !== null
            && $returnedDistrict !== null
            && strcasecmp($returnedCity, $city) === 0
            && strcasecmp($returnedDistrict, $district) === 0;
    }
}