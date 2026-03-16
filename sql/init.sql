/*
Script para la creación de las tablas propuestas para el sistema de MediNet
Hecho para correr en el motor de PostgreSQL
*/

CREATE DATABASE medinet;

-- tabla usuarios
CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    FOREIGN KEY (id_user) REFERENCES users(id)
);

-- tabla doctores
CREATE TABLE doctors (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_user) REFERENCES users(id)
);

-- tabla secretarias
CREATE TABLE secretaries (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (id_user) REFERENCES users(id)
);

-- tabla especialidades
CREATE TABLE specialties (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    specialty TEXT NOT NULL UNIQUE
);

-- tabla doctor_especialidad
CREATE TABLE doctor_specialty (
    id_doctor INTEGER NOT NULL,
    id_specialty INTEGER NOT NULL,
    PRIMARY KEY (id_doctor, id_specialty),
    FOREIGN KEY (id_doctor) REFERENCES doctors(id),
    FOREIGN KEY (id_specialty) REFERENCES specialties(id)
);

-- tabla clinicas
CREATE TABLE clinics (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- tabla doctor_clinica
CREATE TABLE doctor_clinic (
    id_doctor INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    start_date DATE NOT NULL,
    appointment_duration INTEGER NOT NULL,
    PRIMARY KEY (id_doctor, id_clinic),
    FOREIGN KEY (id_doctor) REFERENCES doctors(id),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id),
    CHECK (appointment_duration > 0)
);

-- tabla secretaria_clinica
CREATE TABLE secretary_clinic (
    id_secretary INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    start_date DATE NOT NULL,
    PRIMARY KEY (id_secretary, id_clinic),
    FOREIGN KEY (id_secretary) REFERENCES secretaries(id),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id)
);

-- tabla horarios
CREATE TABLE schedules (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_doctor INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (id_doctor) REFERENCES doctors(id),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id),
    CHECK (day_of_week BETWEEN 0 AND 6),
    CHECK (start_time < end_time)
);

-- tabla bloqueos_horario
CREATE TABLE schedule_blockades (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_schedule INTEGER NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (id_schedule) REFERENCES schedules(id),
    CHECK (start_time < end_time)
);

-- tabla solicitudes_cita
CREATE TABLE appointment_requests (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_patient INTEGER NOT NULL,
    id_schedule INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status TEXT NOT NULL,
    reason TEXT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    FOREIGN KEY (id_patient) REFERENCES patients(id),
    FOREIGN KEY (id_schedule) REFERENCES schedules(id),
    CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled'))
);

-- tabla citas
CREATE TABLE appointments (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_schedule INTEGER NOT NULL,
    id_request INTEGER NOT NULL UNIQUE,
    id_patient INTEGER NOT NULL,
    date DATE NOT NULL,
    status TEXT NOT NULL,
    start_time TIME NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_schedule) REFERENCES schedules(id),
    FOREIGN KEY (id_request) REFERENCES appointment_requests(id),
    FOREIGN KEY (id_patient) REFERENCES patients(id),
    CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled'))
);

-- tabla lista_espera
CREATE TABLE waitlist (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_patient INTEGER NOT NULL,
    id_target_appointment INTEGER NOT NULL,
    id_fallback_appointment INTEGER NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_patient) REFERENCES patients(id),
    FOREIGN KEY (id_target_appointment) REFERENCES appointments(id),
    FOREIGN KEY (id_fallback_appointment) REFERENCES appointments(id),
    CHECK (status IN ('active', 'notified', 'expired', 'fulfilled'))
);

-- tabla notificaciones
CREATE TABLE notifications (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL,
    channel TEXT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES users(id),
    CHECK (type IN ('reminder', 'cancellation', 'reschedule', 'confirmation')),
    CHECK (channel IN ('email', 'sms', 'push'))
);

-- tabla preferencias_notificacion
CREATE TABLE notification_preferences (
    id_user INTEGER NOT NULL,
    channel TEXT NOT NULL,
    PRIMARY KEY (id_user, channel),
    FOREIGN KEY (id_user) REFERENCES users(id),
    CHECK (channel IN ('email', 'sms', 'push'))
);