<?php

use App\Broadcasting\DoctorChannel;
use App\Broadcasting\OrganizationChannel;
use App\Broadcasting\PatientChannel;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('patients.{patientId}', PatientChannel::class);
Broadcast::channel('doctors.{doctorId}', DoctorChannel::class);
Broadcast::channel('organizations.{clientId}', OrganizationChannel::class);
