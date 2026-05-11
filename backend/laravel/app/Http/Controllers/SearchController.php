<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\SearchService;
use Illuminate\Support\Facades\Log;

class SearchController extends Controller
{
    public function __construct(private SearchService $service)
    {
    }

    public function index(Request $request)
    {
        $totalStart = microtime(true);
        $queryStart = microtime(true);
        $query = trim($request->query('q', ''));

        Log::debug('search.controller.query_parsed', [
            'elapsed_ms' => $this->elapsedMs($queryStart),
            'query_length' => strlen($query),
        ]);

        $serviceStart = microtime(true);
        $result = $this->service->search($query);

        Log::debug('search.controller.service_completed', [
            'elapsed_ms' => $this->elapsedMs($serviceStart),
            'doctors_count' => count($result['doctors']),
            'clinics_count' => count($result['clinics']),
        ]);

        $responseStart = microtime(true);
        $response = response()->json($result);

        Log::debug('search.controller.response_created', [
            'elapsed_ms' => $this->elapsedMs($responseStart),
        ]);
        Log::debug('search.controller.finished', [
            'elapsed_ms' => $this->elapsedMs($totalStart),
        ]);

        return $response;
    }

    private function elapsedMs(float $start): float
    {
        return round((microtime(true) - $start) * 1000, 2);
    }
}
