<?php

namespace App\Services;

use App\Repositories\SearchRepository;

class SearchService
{
    private const MAX_RESULTS = 16;

    public function __construct(private SearchRepository $repository) {}

    public function search(string $query): array
    {
        if ($query === '') {
            return [
                'doctors' => $this->repository->randomDoctors(self::MAX_RESULTS),
                'clinics' => $this->repository->randomClinics(self::MAX_RESULTS),
            ];
        }

        return [
            'doctors' => $this->repository->searchDoctors($query, self::MAX_RESULTS),
            'clinics' => $this->repository->searchClinics($query, self::MAX_RESULTS),
        ];
    }
}
