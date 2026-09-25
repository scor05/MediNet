<?php

namespace Tests\Unit\Services;

use App\Repositories\ScheduleRepository;
use App\Services\ScheduleService;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class ScheduleServiceTest extends TestCase
{
    private array $scheduleData = [
        'id_doctor' => 36,
        'id_clinic' => 1,
        'day_of_week' => 5,
        'start_time' => '08:00',
        'end_time' => '16:00',
        'duration' => 60,
    ];

    public function test_it_rejects_a_doctor_and_clinic_from_unrelated_organizations(): void
    {
        $repository = $this->createMock(ScheduleRepository::class);
        $repository->expects($this->once())
            ->method('canCreateForDoctorAtClinic')
            ->with(2, 36, 1)
            ->willReturn(false);
        $repository->expects($this->never())->method('create');

        $this->expectException(ValidationException::class);

        (new ScheduleService($repository))->create($this->scheduleData, 2);
    }

    public function test_it_creates_an_authorized_non_overlapping_schedule(): void
    {
        $repository = $this->createMock(ScheduleRepository::class);
        $created = (object) ['id' => 20];
        $repository->expects($this->once())
            ->method('canCreateForDoctorAtClinic')
            ->with(2, 36, 1)
            ->willReturn(true);
        $repository->expects($this->once())
            ->method('findOverlappingSchedule')
            ->with(36, 5, '08:00', '16:00', null)
            ->willReturn(false);
        $repository->expects($this->once())
            ->method('create')
            ->with($this->scheduleData)
            ->willReturn($created);

        $result = (new ScheduleService($repository))->create(
            $this->scheduleData,
            2,
        );

        $this->assertSame($created, $result);
    }

    public function test_it_updates_an_authorized_schedule_and_uses_the_database_day_field(): void
    {
        $repository = $this->createMock(ScheduleRepository::class);
        $schedule = (object) [
            'id_doctor' => 36,
            'id_clinic' => 1,
            'day_of_week' => 5,
            'start_time' => '08:00',
            'end_time' => '16:00',
        ];
        $data = [
            'id_clinic' => 2,
            'start_time' => '09:00',
            'end_time' => '15:00',
            'duration' => 30,
        ];
        $repository->method('findById')->with(20)->willReturn($schedule);
        $repository->expects($this->once())
            ->method('canCreateForDoctorAtClinic')
            ->with(2, 36, 2)
            ->willReturn(true);
        $repository->expects($this->once())
            ->method('findOverlappingSchedule')
            ->with(36, 5, '09:00', '15:00', 20)
            ->willReturn(false);
        $repository->expects($this->once())
            ->method('update')
            ->with(20, $data)
            ->willReturn((object) ['id' => 20]);

        (new ScheduleService($repository))->update(20, $data, 2);
    }

    public function test_delete_deactivates_an_authorized_schedule(): void
    {
        $repository = $this->createMock(ScheduleRepository::class);
        $repository->method('findById')->with(20)->willReturn((object) [
            'id_doctor' => 36,
            'id_clinic' => 1,
        ]);
        $repository->expects($this->once())
            ->method('canCreateForDoctorAtClinic')
            ->with(36, 36, 1)
            ->willReturn(true);
        $repository->expects($this->once())->method('deactivate')->with(20);

        (new ScheduleService($repository))->delete(20, 36);
    }
}
