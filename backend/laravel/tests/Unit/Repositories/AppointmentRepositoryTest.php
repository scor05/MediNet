<?php

namespace Tests\Unit\Repositories;

use App\Models\Appointment;
use App\Repositories\AppointmentRepository;
use Mockery;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;
use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

class AppointmentRepositoryTest extends TestCase
{
    use MockeryPHPUnitIntegration;

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_find_by_id_returns_the_eloquent_result(): void
    {
        $expected = (object) [
            'id' => 42,
            'status' => 'accepted',
        ];

        $model = Mockery::mock('alias:'.Appointment::class);
        $model->shouldReceive('findOrFail')
            ->once()
            ->with(42)
            ->andReturn($expected);

        $repository = new AppointmentRepository;

        $this->assertSame($expected, $repository->findById(42));
    }
}
