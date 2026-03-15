/*
Script para la creación de las tablas propuestas para el sistema de MediNet
Hecho para correr en el motor de PostgreSQL
*/


CREATE DATABASE IF NOT EXISTS mediNet;

CREATE TABLE users(
    -- identity para que sea AUTOINCREMENT
    id_user INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN NOT NULL,
    phone TEXT NOT NULL,
    phone_aux TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at DATE NOT NULL
);

CREATE TABLE patients(
    id_pac INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL,
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);

CREATE TABLE doctors(
    id_doc INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL,
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);

CREATE TABLE specialties(
    id_spec INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE doctor_specialty(
    id_doc INTEGER NOT NULL,
    id_spec INTEGER NOT NULL,
    PRIMARY KEY (id_doc, id_spec),
    FOREIGN KEY (id_doc) REFERENCES doctors(id_doc),
    FOREIGN KEY (id_spec) REFERENCES specialties(id_spec)
);


CREATE TABLE secretaries(
    id_sec INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_user INTEGER NOT NULL,
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);
