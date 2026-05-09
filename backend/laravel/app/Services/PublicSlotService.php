<?php

namespace App\Services;

use App\Repositories\PublicSlotRepository;

class PublicSlotService
{
    public function __construct(private PublicSlotRepository $repository)
    {
    }

    public function getAvailableSlots(array $filters): array
    {
        return $this->repository->getAvailableSlots(
            $filters['doctor_id'],
            $filters['clinic_id'],
            $filters['date']
        );
    }
}