<?php

namespace Tests\Unit\Services;

use App\Repositories\SearchRepository;
use App\Services\SearchService;
use PHPUnit\Framework\TestCase;

class SearchServiceTest extends TestCase
{
    public function test_empty_query_returns_random_suggestions_limited_to_sixteen(): void
    {
        $repository = $this->createMock(SearchRepository::class);
        $doctors = [(object) ['id' => 1, 'name' => 'Doctor']];
        $clinics = [(object) ['id' => 2, 'name' => 'Clínica']];

        $repository->expects($this->once())
            ->method('randomDoctors')
            ->with(16)
            ->willReturn($doctors);
        $repository->expects($this->once())
            ->method('randomClinics')
            ->with(16)
            ->willReturn($clinics);

        $result = (new SearchService($repository))->search('');

        $this->assertSame($doctors, $result['doctors']);
        $this->assertSame($clinics, $result['clinics']);
    }

    public function test_non_empty_query_returns_matching_results_limited_to_sixteen(): void
    {
        $repository = $this->createMock(SearchRepository::class);

        $repository->expects($this->once())
            ->method('searchDoctors')
            ->with('monroy', 16)
            ->willReturn([]);
        $repository->expects($this->once())
            ->method('searchClinics')
            ->with('monroy', 16)
            ->willReturn([]);

        $result = (new SearchService($repository))->search('monroy');

        $this->assertSame([], $result['doctors']);
        $this->assertSame([], $result['clinics']);
    }
}
