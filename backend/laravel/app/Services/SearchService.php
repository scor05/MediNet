<?php

namespace App\Services;

use App\Repositories\SearchRepository;
use Illuminate\Support\Facades\Log;

class SearchService
{
    public function __construct(private SearchRepository $repository)
    {
    }

    public function search(string $query): array
    {
        $totalStart = microtime(true);

        Log::debug('search.service.start', [
            'query_length' => strlen($query),
        ]);

        if ($query === '') {
            Log::debug('search.service.empty_query', [
                'elapsed_ms' => $this->elapsedMs($totalStart),
            ]);

            return [
                'doctors' => [],
                'clinics' => [],
            ];
        }

        $doctorsStart = microtime(true);
        $doctors = $this->repository->searchDoctors($query);

        Log::debug('search.service.doctors_completed', [
            'elapsed_ms' => $this->elapsedMs($doctorsStart),
            'count' => count($doctors),
        ]);

        $clinicsStart = microtime(true);
        $clinics = $this->repository->searchClinics($query);

        Log::debug('search.service.clinics_completed', [
            'elapsed_ms' => $this->elapsedMs($clinicsStart),
            'count' => count($clinics),
        ]);

        Log::debug('search.service.finished', [
            'elapsed_ms' => $this->elapsedMs($totalStart),
            'doctors_count' => count($doctors),
            'clinics_count' => count($clinics),
        ]);

        return [
            'doctors' => $doctors,
            'clinics' => $clinics,
        ];
    }

    private function elapsedMs(float $start): float
    {
        return round((microtime(true) - $start) * 1000, 2);
    }
}
