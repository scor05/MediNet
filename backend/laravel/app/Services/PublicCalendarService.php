<?php

namespace App\Services;

use App\Repositories\PublicCalendarRepository;

class PublicCalendarService
{
    public function __construct(private PublicCalendarRepository $repository)
    {
    }

    public function getPublicCalendar(array $filters)
    {
        return $this->repository->getPublicCalendar($filters);
    }
}