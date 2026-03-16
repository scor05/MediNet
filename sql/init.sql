/*
Script para la creación de las tablas propuestas para el sistema de MediNet
Hecho para correr en el motor de PostgreSQL
*/

CREATE DATABASE medinet;

-- tabla usuarios
CREATE TABLE users (
    id_user INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (role IN ('patient', 'doctor', 'secretary'))
);

-- tabla pacientes
CREATE TABLE patients (
    id_pac INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);

-- tabla doctores
CREATE TABLE doctors (
    id_doc INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);

-- tabla secretarias
CREATE TABLE secretaries (
    id_sec INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);

-- tabla especialidades
CREATE TABLE specialties (
    id_spec INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- tabla doctor_especialidad
CREATE TABLE doctor_specialty (
    id_doc INTEGER NOT NULL,
    id_spec INTEGER NOT NULL,
    PRIMARY KEY (id_doc, id_spec),
    FOREIGN KEY (id_doc) REFERENCES doctors(id_doc),
    FOREIGN KEY (id_spec) REFERENCES specialties(id_spec)
);

-- tabla clinicas
CREATE TABLE clinics (
    id_clinic INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- tabla doctor_clinica
CREATE TABLE doctor_clinic (
    id_doc INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    start_date DATE NOT NULL,
    appointment_duration INTEGER NOT NULL,
    PRIMARY KEY (id_doc, id_clinic),
    FOREIGN KEY (id_doc) REFERENCES doctors(id_doc),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id_clinic),
    CHECK (appointment_duration > 0)
);

-- tabla secretaria_clinica
CREATE TABLE secretary_clinic (
    id_sec INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    start_date DATE NOT NULL,
    PRIMARY KEY (id_sec, id_clinic),
    FOREIGN KEY (id_sec) REFERENCES secretaries(id_sec),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id_clinic)
);

-- tabla horarios
CREATE TABLE schedules (
    id_schedule INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_doc INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (id_doc) REFERENCES doctors(id_doc),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id_clinic),
    CHECK (day_of_week BETWEEN 0 AND 6),
    CHECK (start_time < end_time)
);

-- tabla bloqueos_horario
CREATE TABLE schedule_blockades (
    id_block INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_schedule INTEGER NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (id_schedule) REFERENCES schedules(id_schedule),
    CHECK (start_time < end_time)
);

-- tabla solicitudes_cita
CREATE TABLE appointment_requests (
    id_request INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pac INTEGER NOT NULL,
    id_schedule INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status TEXT NOT NULL,
    reason TEXT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    FOREIGN KEY (id_pac) REFERENCES patients(id_pac),
    FOREIGN KEY (id_schedule) REFERENCES schedules(id_schedule),
    CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled'))
);

-- tabla citas
CREATE TABLE appointments (
    id_appointment INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_schedule INTEGER NOT NULL,
    id_request INTEGER NOT NULL UNIQUE,
    id_pac INTEGER NOT NULL,
    id_doc INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    date DATE NOT NULL,
    status TEXT NOT NULL,
    start_time TIME NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_schedule) REFERENCES schedules(id_schedule),
    FOREIGN KEY (id_request) REFERENCES appointment_requests(id_request),
    FOREIGN KEY (id_pac) REFERENCES patients(id_pac),
    FOREIGN KEY (id_doc) REFERENCES doctors(id_doc),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id_clinic),
    CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled'))
);

-- tabla lista_espera
CREATE TABLE waitlist (
    id_waitlist INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pac INTEGER NOT NULL,
    id_target_appointment INTEGER NOT NULL,
    id_fallback_appointment INTEGER NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pac) REFERENCES patients(id_pac),
    FOREIGN KEY (id_target_appointment) REFERENCES appointments(id_appointment),
    FOREIGN KEY (id_fallback_appointment) REFERENCES appointments(id_appointment),
    CHECK (status IN ('active', 'notified', 'expired', 'fulfilled'))
);

-- tabla notificaciones
CREATE TABLE notifications (
    id_notif INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL,
    channel TEXT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES users(id_user),
    CHECK (type IN ('reminder', 'cancellation', 'reschedule', 'confirmation')),
    CHECK (channel IN ('email', 'sms', 'push'))
);

-- tabla preferencias_notificacion
CREATE TABLE notification_preferences (
    id_user INTEGER NOT NULL,
    channel TEXT NOT NULL,
    PRIMARY KEY (id_user, channel),
    FOREIGN KEY (id_user) REFERENCES users(id_user),
    CHECK (channel IN ('email', 'sms', 'push'))
);