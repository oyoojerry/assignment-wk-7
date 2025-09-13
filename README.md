Clinic Booking System Database
Overview
The Clinic Booking System is a relational database designed to manage appointments, patient records, doctor information, and clinic operations for a medical facility. This SQL schema provides the foundation for a comprehensive clinic management system with support for multi-specialty practices, room management, and service tracking.

Database Schema Details
Core Tables
specialties - Stores medical specialties (e.g., Cardiology, Pediatrics)

doctors - Contains doctor information and credentials

doctor_specialties - Junction table linking doctors to their specialties

patients - Stores patient demographic information

patient_profiles - Extended medical information for patients (allergies, history)

rooms - Physical consultation rooms and their capacities

services - Medical services offered with pricing

appointments - Core booking table with status tracking

appointment_services - Links appointments to services provided

payments - Payment processing and tracking

prescriptions - Digital prescription records

users - Clinic staff authentication and roles

Key Features
Support for multiple medical specialties per doctor

Comprehensive patient medical history tracking

Room availability management

Service-based billing system

Payment processing with multiple methods

Prescription management linked to appointments

Role-based access control for clinic staff

Installation
Execute the SQL script in your MySQL/MariaDB database server:

bash
mysql -u [username] -p < clinic_booking_system.sql
The script will:

Create the clinic_booking database

Set appropriate character set (utf8mb4)

Create all tables with constraints

Establish relationships through foreign keys

Create indexes for performance optimization

Create a view for upcoming appointments

Usage Examples
View Upcoming Appointments
sql
SELECT * FROM vw_patient_upcoming_appointments 
WHERE patient_id = [ID] 
ORDER BY start_time;
Find Doctors by Specialty
sql
SELECT d.*, s.name as specialty
FROM doctors d
JOIN doctor_specialties ds ON d.doctor_id = ds.doctor_id
JOIN specialties s ON ds.specialty_id = s.specialty_id
WHERE s.name = 'Cardiology';
Check Appointment Status
sql
SELECT a.*, p.first_name, p.last_name, d.first_name as doctor_first, d.last_name as doctor_last
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.status = 'scheduled';
Design Considerations
Data Integrity: Foreign key constraints ensure relational integrity

Performance: Indexes on frequently queried columns (doctor_id, patient_id, start_time)

Flexibility: ENUM types used for status fields that have predefined options

Auditability: Created_at timestamps on relevant tables

Security: Separate users table for authentication and authorization

Entity-Relationship Diagram (ERD) Relationships
Based on the provided SQL schema, here are the relationships between entities for an ERD:

One-to-Many Relationships
Doctors → Appointments

One doctor can have many appointments

Foreign Key: appointments.doctor_id → doctors.doctor_id

Patients → Appointments

One patient can have many appointments

Foreign Key: appointments.patient_id → patients.patient_id

Patients → Payments

One patient can have many payments

Foreign Key: payments.patient_id → patients.patient_id

Patients → Prescriptions

One patient can have many prescriptions

Foreign Key: prescriptions.patient_id → patients.patient_id

Doctors → Prescriptions

One doctor can issue many prescriptions

Foreign Key: prescriptions.doctor_id → doctors.doctor_id

Rooms → Appointments

One room can host many appointments (though at different times)

Foreign Key: appointments.room_id → rooms.room_id

Appointments → Prescriptions

One appointment can result in one prescription

Foreign Key: prescriptions.appointment_id → appointments.appointment_id

Many-to-Many Relationships
Doctors ↔ Specialties

Implemented through: doctor_specialties junction table

A doctor can have multiple specialties

A specialty can be associated with multiple doctors

Appointments ↔ Services

Implemented through: appointment_services junction table

An appointment can include multiple services

A service can be part of multiple appointments

One-to-One Relationship
Patients → Patient Profiles

One patient has exactly one profile

Foreign Key: patient_profiles.patient_id → patients.patient_id

Optional Relationships
Appointments → Payments

One appointment can have multiple payments (or none)

Foreign Key: payments.appointment_id → appointments.appointment_id

Entity Attributes
Doctors

doctor_id (PK), first_name, last_name, email, phone, license_number, active, created_at

Patients

patient_id (PK), first_name, last_name, email, phone, date_of_birth, national_id, created_at

Patient Profiles

patient_id (PK, FK), emergency_contact_name, emergency_contact_phone, known_allergies, medical_history

Specialties

specialty_id (PK), name, description

Rooms

room_id (PK), name, location_description, capacity

Services

service_id (PK), name, description, price

Appointments

appointment_id (PK), patient_id (FK), doctor_id (FK), room_id (FK), status, start_time, end_time, notes, created_at

Payments

payment_id (PK), appointment_id (FK), patient_id (FK), amount, method, status, paid_at

Prescriptions

prescription_id (PK), appointment_id (FK), doctor_id (FK), patient_id (FK), prescribed_at, instructions

Users

user_id (PK), username, password_hash, full_name, role, email, created_at

This ERD represents a comprehensive clinic management system with support for appointment scheduling, patient records, service billing, and prescription management.
