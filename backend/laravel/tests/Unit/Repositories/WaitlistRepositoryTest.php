<?php

namespace Tests\Unit\Repositories;

use App\Models\Waitlist;
use App\Repositories\WaitlistRepository;
use Mockery;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;
use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

class WaitlistRepositoryTest extends TestCase
{
    use MockeryPHPUnitIntegration;

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_fallback_appointment_continues_the_original_fifo_queue(): void
    {
        $fallbackLookup = Mockery::mock();
        $queue = Mockery::mock();
        $model = Mockery::mock('alias:'.Waitlist::class);
        $firstWaiting = $model;

        $model->shouldReceive('where')
            ->once()
            ->with('id_fallback_appointment', 61)
            ->andReturn($fallbackLookup);
        $fallbackLookup->shouldReceive('value')
            ->once()
            ->with('id_target_appointment')
            ->andReturn(44);

        $model->shouldReceive('where')
            ->once()
            ->with('id_target_appointment', 44)
            ->andReturn($queue);
        $queue->shouldReceive('where')
            ->once()
            ->with('status', 'waiting')
            ->andReturnSelf();
        $queue->shouldReceive('orderBy')
            ->once()
            ->with('created_at')
            ->andReturnSelf();
        $queue->shouldReceive('orderBy')
            ->once()
            ->with('id')
            ->andReturnSelf();
        $queue->shouldReceive('lockForUpdate')->once()->andReturnSelf();
        $queue->shouldReceive('first')->once()->andReturn($firstWaiting);

        $result = (new WaitlistRepository)
            ->findFirstWaitingForFreedAppointment(61);

        $this->assertSame($firstWaiting, $result);
    }
}
