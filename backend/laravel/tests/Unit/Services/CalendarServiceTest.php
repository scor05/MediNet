<?php

namespace Tests\Unit\Services;

use App\Repositories\CalendarRepository;
use App\Services\CalendarService;
use PHPUnit\Framework\TestCase;

class CalendarServiceTest extends TestCase
{
    public function test_filtered_secretary_calendar_does_not_include_blockades(): void
    {
        $repository = $this->createMock(CalendarRepository::class);

        $repository->expects($this->once())
            ->method('getAppointmentsForSecretary')
            ->with(13, null, null, null, null, 'requested')
            ->willReturn([
                (object) [
                    'id' => 57,
                    'id_schedule' => 2,
                    'id_patient' => 13,
                    'date' => '2026-08-11',
                    'start_time' => '11:00:00',
                    'status' => 'requested',
                    'appointment_duration' => 30,
                    'created_at' => '2026-08-11 19:39:28',
                    'created_by' => 13,
                    'updated_at' => '2026-08-11 19:39:28',
                    'updated_by' => 13,
                    'doctor_id' => 4,
                    'doctor_name' => 'Doctor',
                    'patient_name' => 'Ratoncito Perezz',
                    'clinic_id' => 1,
                    'clinic_name' => 'Zona 15',
                ],
            ]);

        $repository->expects($this->never())
            ->method('getBlockadesForSecretary');

        $service = new CalendarService($repository);
        $result = $service->getSecretaryCalendar(
            secretaryId: 13,
            doctorId: null,
            clinicId: null,
            dateFrom: null,
            dateTo: null,
            status: 'requested',
        );

        $this->assertCount(1, $result);
        $this->assertSame(57, $result[0]['id']);
        $this->assertSame('Ratoncito Perezz', $result[0]['patient']['name']);
        $this->assertSame('requested', $result[0]['status']);
        $this->assertArrayNotHasKey('type', $result[0]);
    }
}
