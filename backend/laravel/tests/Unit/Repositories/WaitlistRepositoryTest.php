<?php

namespace Tests\Unit\Repositories;

use App\Models\Waitlist;
use App\Repositories\WaitlistRepository;
use Illuminate\Support\Facades\DB;
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
    public function test_find_by_patient_returns_appointment_context_for_the_ui(): void
    {
        $expected = [(object) [
            'id' => 3,
            'doctor_name' => 'Ana Lopez',
            'clinic_name' => 'Zona 15',
            'target_date' => '2026-08-20',
            'target_start_time' => '09:30:00',
        ]];
        $query = Mockery::mock();
        $db = Mockery::mock('alias:'.DB::class);

        $db->shouldReceive('table')->once()->with('waitlists')->andReturn($query);
        $query->shouldReceive('join')->times(4)->andReturnSelf();
        $query->shouldReceive('where')
            ->once()
            ->with('waitlists.id_patient', 7)
            ->andReturnSelf();
        $query->shouldReceive('select')
            ->once()
            ->with([
                'waitlists.*',
                'doctor.name AS doctor_name',
                'clinics.name AS clinic_name',
                'target.date AS target_date',
                'target.start_time AS target_start_time',
            ])
            ->andReturnSelf();
        $query->shouldReceive('orderByDesc')
            ->once()
            ->with('waitlists.created_at')
            ->andReturnSelf();
        $query->shouldReceive('orderByDesc')
            ->once()
            ->with('waitlists.id')
            ->andReturnSelf();
        $query->shouldReceive('get')->once()->andReturn($expected);

        $result = (new WaitlistRepository)->findByPatient(7);

        $this->assertSame($expected, $result);
    }

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
