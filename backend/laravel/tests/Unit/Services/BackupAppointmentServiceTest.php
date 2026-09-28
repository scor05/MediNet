<?php

namespace Tests\Unit\Services;

use App\Models\Appointment;
use App\Models\Waitlist;
use App\Repositories\AppointmentRepository;
use App\Repositories\WaitlistRepository;
use App\Services\AppointmentAvailabilityService;
use App\Services\AppointmentRealtimeService;
use App\Services\BackupAppointmentService;
use App\Services\UserService;
use App\Services\WaitlistRealtimeService;
use Illuminate\Support\Facades\DB;
use Mockery;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;
use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

class BackupAppointmentServiceTest extends TestCase
{
    use MockeryPHPUnitIntegration;

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_create_persists_and_links_a_pending_backup_atomically(): void
    {
        $db = Mockery::mock('alias:'.DB::class);
        $db->shouldReceive('transaction')
            ->once()
            ->andReturnUsing(fn (callable $callback) => $callback());

        $waitlistRepository = $this->createMock(WaitlistRepository::class);
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $userService = $this->createMock(UserService::class);
        $availabilityService = $this->createMock(AppointmentAvailabilityService::class);
        $realtimeService = $this->createMock(AppointmentRealtimeService::class);
        $waitlistRealtimeService = $this->createMock(WaitlistRealtimeService::class);

        $waitlist = new Waitlist;
        $waitlist->forceFill([
            'id' => 5,
            'id_patient' => 19,
            'id_target_appointment' => 44,
            'id_backup_appointment' => null,
            'backup_declined_at' => null,
            'status' => 'waiting',
        ]);
        $target = new Appointment;
        $target->forceFill([
            'id' => 44,
            'id_schedule' => 8,
            'date' => '2026-10-05',
            'start_time' => '09:00:00',
        ]);
        $schedule = (object) ['id' => 12];
        $backup = new Appointment;
        $backup->forceFill(['id' => 71, 'status' => 'backup_pending']);
        $updatedWaitlist = clone $waitlist;
        $updatedWaitlist->id_backup_appointment = 71;

        $waitlistRepository->expects($this->once())
            ->method('findByIdForUpdate')
            ->with(5)
            ->willReturn($waitlist);
        $appointmentRepository->expects($this->once())
            ->method('findById')
            ->with(44)
            ->willReturn($target);
        $availabilityService->expects($this->once())
            ->method('resolveAlternative')
            ->with($target, '2026-10-06', '10:00')
            ->willReturn($schedule);
        $userService->expects($this->once())
            ->method('getById')
            ->with(19)
            ->willReturn((object) ['name' => 'Paciente Uno']);
        $appointmentRepository->expects($this->once())
            ->method('create')
            ->with([
                'id_schedule' => 12,
                'id_patient' => 19,
                'name_patient' => 'Paciente Uno',
                'date' => '2026-10-06',
                'start_time' => '10:00',
                'status' => 'backup_pending',
                'created_by' => 19,
                'updated_by' => 19,
            ])
            ->willReturn($backup);
        $waitlistRepository->expects($this->once())
            ->method('update')
            ->with(5, ['id_backup_appointment' => 71])
            ->willReturn($updatedWaitlist);
        $realtimeService->expects($this->once())
            ->method('created')
            ->with($backup);
        $waitlistRealtimeService->expects($this->once())
            ->method('updated')
            ->with($this->isInstanceOf(Waitlist::class), $updatedWaitlist);

        $result = (new BackupAppointmentService(
            $waitlistRepository,
            $appointmentRepository,
            $userService,
            $availabilityService,
            $realtimeService,
            $waitlistRealtimeService,
        ))->create(5, 19, [
            'id_schedule' => 12,
            'date' => '2026-10-06',
            'start_time' => '10:00',
        ]);

        $this->assertSame($backup, $result);
    }
}
