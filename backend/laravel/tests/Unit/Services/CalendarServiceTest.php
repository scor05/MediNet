<?php

namespace Tests\Unit\Services;

use App\Repositories\CalendarRepository;
use App\Services\CalendarService;
use PHPUnit\Framework\TestCase;

class CalendarServiceTest extends TestCase
{
    public function test_doctor_calendar_includes_original_slot_for_backup(): void
    {
        $repository = $this->createMock(CalendarRepository::class);
        $repository->expects($this->once())
            ->method('getAppointmentsForDoctor')
            ->willReturn([
                (object) [
                    'id' => 81,
                    'id_schedule' => 5,
                    'id_patient' => 20,
                    'date' => '2026-10-05',
                    'start_time' => '14:00:00',
                    'status' => 'backup_pending',
                    'appointment_duration' => 30,
                    'created_at' => '2026-09-27 10:00:00',
                    'created_by' => 20,
                    'updated_at' => '2026-09-27 10:00:00',
                    'updated_by' => 20,
                    'doctor_id' => 4,
                    'doctor_name' => 'Doctor',
                    'doctor_phone' => null,
                    'patient_name' => 'Paciente',
                    'clinic_id' => 1,
                    'clinic_name' => 'Zona 15',
                    'backup_target_date' => '2026-10-04',
                    'backup_target_start_time' => '09:30:00',
                ],
            ]);
        $repository->expects($this->once())
            ->method('getBlockadesForDoctor')
            ->willReturn([]);

        $result = (new CalendarService($repository))->getDoctorCalendar(
            doctorId: 4,
            clientId: null,
            clinicId: null,
            dateFrom: null,
            dateTo: null,
        );

        $this->assertSame(
            '2026-10-04',
            $result[0]['backup_target_date']
        );
        $this->assertSame(
            '09:30:00',
            $result[0]['backup_target_start_time']
        );
    }

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
                    'doctor_phone' => null,
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
