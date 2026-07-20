<?php

namespace Tests\Unit\Http\Controllers;

use App\Http\Controllers\SpecialtyController;
use App\Services\SpecialtyService;
use Tests\Unit\UnitTestCase;

class SpecialtyControllerTest extends UnitTestCase
{
    public function test_index_returns_the_specialties_from_the_service_as_json(): void
    {
        $specialties = [
            ['id' => 1, 'specialty' => 'Cardiologia'],
            ['id' => 2, 'specialty' => 'Pediatria'],
        ];

        $service = $this->createMock(SpecialtyService::class);
        $service->expects($this->once())
            ->method('getAll')
            ->willReturn($specialties);

        $response = (new SpecialtyController($service))->index();

        $this->assertSame(200, $response->getStatusCode());
        $this->assertSame($specialties, $response->getData(true));
    }
}
