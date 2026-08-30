<?php

use App\Broadcasting\PatientChannel;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('patients.{patientId}', PatientChannel::class);
