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
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    FOREIGN KEY (id_doctor) REFERENCES users(id),
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

-- tabla horarios
CREATE TABLE schedules (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_doctor INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status INT NOT NULL,
    duration INT NOT NULL,
    FOREIGN KEY (id_doctor) REFERENCES user(id),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id),
    CHECK (day_of_week BETWEEN 0 AND 6),
    CHECK (start_time < end_time),
    CHECK (status BETWEEN 0 AND 1)
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

-- tabla citas
CREATE TABLE appointments (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_schedule INTEGER NOT NULL,
    id_patient INTEGER NOT NULL,
    date DATE NOT NULL,
    status TEXT NOT NULL,
    start_time TIME NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER NOT NULL,
    last_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated_by INTEGER NOT NULL,
    FOREIGN KEY (id_schedule) REFERENCES schedules(id),
    FOREIGN KEY (id_patient) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (last_updated_by) REFERENCES users(id),
    CHECK (status IN ('requested', 'accepted', 'rejected', 'cancelled', 'rescheduled'))
);

-- tabla lista_espera
CREATE TABLE waitlists (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_patient INTEGER NOT NULL,
    id_target_appointment INTEGER NOT NULL,
    id_fallback_appointment INTEGER NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_patient) REFERENCES users(id),
    FOREIGN KEY (id_target_appointment) REFERENCES appointments(id),
    FOREIGN KEY (id_fallback_appointment) REFERENCES appointments(id),
    CHECK (status IN ('active', 'notified', 'expired', 'fulfilled', 'cancelled'))
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

-- tabla clientes
CREATE TABLE clients (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_admin INTEGER NOT NULL,
    nit INTEGER NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (id_admin) REFERENCES users(id)
);

-- tabla clientes_usuarios
CREATE TABLE clients_users (
    id_client INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    PRIMARY KEY (id_client, id_user),
    FOREIGN KEY (id_client) REFERENCES clients(id),
    FOREIGN KEY (id_user) REFERENCES users(id)
);

-- tabla clientes-clinicas
CREATE TABLE clients_clinics (
    id_client INTEGER NOT NULL,
    id_clinic INTEGER NOT NULL,
    PRIMARY KEY (id_client, id_clinic),
    FOREIGN KEY (id_client) REFERENCES clients(id),
    FOREIGN KEY (id_clinic) REFERENCES clinics(id)
);