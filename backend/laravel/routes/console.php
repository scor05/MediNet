<?php

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

Schedule::command('backups:finalize-due')
    ->everyMinute()
    ->withoutOverlapping();
