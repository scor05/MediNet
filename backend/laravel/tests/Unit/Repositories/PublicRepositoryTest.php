<?php

namespace Tests\Unit\Repositories;

use App\Repositories\PublicRepository;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Mockery;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;
use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

class PublicRepositoryTest extends TestCase
{
    use MockeryPHPUnitIntegration;

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_find_slots_includes_occupied_slots_and_excludes_blocked_slots(): void
    {
        $scheduleQuery = Mockery::mock();
        $appointmentQuery = Mockery::mock();
        $blockadeQuery = Mockery::mock();
        $db = Mockery::mock('alias:'.DB::class);

        $schedule = (object) [
            'id' => 12,
            'start_time' => '08:00:00',
            'end_time' => '10:00:00',
            'duration' => 30,
            'doctor_id' => 4,
            'doctor_name' => 'Dra. Lopez',
            'clinic_id' => 6,
            'clinic_name' => 'Zona 15',
        ];

        $db->shouldReceive('table')->once()->with('schedules')->andReturn($scheduleQuery);
        $scheduleQuery->shouldReceive('join')->twice()->andReturnSelf();
        $scheduleQuery->shouldReceive('where')->times(6)->andReturnSelf();
        $scheduleQuery->shouldReceive('select')->once()->andReturnSelf();
        $scheduleQuery->shouldReceive('orderBy')->once()->andReturnSelf();
        $scheduleQuery->shouldReceive('get')->once()->andReturn(new Collection([$schedule]));

        $db->shouldReceive('table')->once()->with('appointments')->andReturn($appointmentQuery);
        $appointmentQuery->shouldReceive('whereIn')->once()->with('id_schedule', [12])->andReturnSelf();
        $appointmentQuery->shouldReceive('where')->once()->with('date', '2026-08-17')->andReturnSelf();
        $appointmentQuery->shouldReceive('whereNotIn')
            ->once()
            ->with('status', ['rejected', 'cancelled'])
            ->andReturnSelf();
        $appointmentQuery->shouldReceive('get')
            ->once()
            ->with(['id_schedule', 'start_time'])
            ->andReturn(new Collection([
                (object) ['id_schedule' => 12, 'start_time' => '08:30:00'],
            ]));

        $db->shouldReceive('table')->once()->with('schedule_blockades')->andReturn($blockadeQuery);
        $blockadeQuery->shouldReceive('whereIn')->once()->with('id_schedule', [12])->andReturnSelf();
        $blockadeQuery->shouldReceive('where')->once()->with('date', '2026-08-17')->andReturnSelf();
        $blockadeQuery->shouldReceive('get')
            ->once()
            ->with(['id_schedule', 'start_time', 'end_time'])
            ->andReturn(new Collection([
                (object) [
                    'id_schedule' => 12,
                    'start_time' => '09:00:00',
                    'end_time' => '09:30:00',
                ],
            ]));

        $slots = (new PublicRepository)->findSlots(4, 6, '2026-08-17');

        $this->assertSame(['08:00', '08:30', '09:30'], array_column($slots, 'start_time'));
        $this->assertSame([false, true, false], array_column($slots, 'is_occupied'));
        $this->assertNotContains('09:00', array_column($slots, 'start_time'));
    }
}
