<?php

namespace App\Services;

use App\Repositories\SearchRepository;

class SearchService
{
    public function __construct(private SearchRepository $repository)
    {
    }

    public function search(string $query): array
    {
        if ($query === '') {
            return [
                'doctors' => [],
                'clinics' => [],
            ];
        }

        return [
            'doctors' => $this->repository->searchDoctors($query),
            'clinics' => $this->repository->searchClinics($query),
        ];
    }
}