<?php

use App\Services\AuthService;
use App\Services\BackupAppointmentService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('backups:finalize-due', function (BackupAppointmentService $service) {
    $count = $service->finalizeDueBackups();
    $this->info("Processed {$count} due backup appointment(s).");
})->purpose('Finalize waitlists whose backup appointment time has arrived');

Artisan::command('users:link-supabase {--apply : Guardar los cambios; sin esta opción solo se muestra el reporte}', function (AuthService $service) {
    $apply = (bool) $this->option('apply');
    $report = $service->linkExistingAccounts($apply);

    if ($report['linked'] !== []) {
        $this->table(['ID', 'Correo', 'Supabase ID'], $report['linked']);
    }

    if ($report['not_found'] !== []) {
        $this->warn('Usuarios sin cuenta en Supabase:');
        $this->table(['ID', 'Correo'], $report['not_found']);
    }

    if ($report['conflicts'] !== []) {
        $this->error('Usuarios con conflictos (no se vincularon):');
        $this->table(['ID', 'Correo', 'Motivo'], $report['conflicts']);
    }

    $count = count($report['linked']);
    $apply
        ? $this->info("Se vincularon {$count} usuario(s).")
        : $this->info("Simulación: se vincularían {$count} usuario(s). Ejecute con --apply para guardar.");
})->purpose('Vincular usuarios existentes con su identificador de Supabase Auth');

Schedule::command('backups:finalize-due')
    ->everyMinute()
    ->withoutOverlapping();
