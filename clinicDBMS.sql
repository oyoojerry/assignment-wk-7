-- week 7 assignment question 1
-- File: clinic_booking_system.sql
-- Description: Creates the clinic_booking database and all tables, constraints, and sample comments.

-- Create the database
-- -----------------------------
CREATE DATABASE IF NOT EXISTS `clinic_booking` CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_general_ci';
USE `clinic_booking`;

-- -----------------------------
-- Table: specialties
-- Purpose: Stores medical specialties (e.g., "General Practice", "Dermatology").
-- -----------------------------
CREATE TABLE IF NOT EXISTS `specialties` (
  `specialty_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  PRIMARY KEY (`specialty_id`),
  UNIQUE KEY `uq_specialty_name` (`name`)
) ENGINE=InnoDB;

-- -----------------------------
-- Table: doctors
-- Purpose: Stores doctors/users that provide consultations.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `doctors` (
  `doctor_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(80) NOT NULL,
  `last_name` VARCHAR(80) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(30),
  `license_number` VARCHAR(100) UNIQUE,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`doctor_id`),
  UNIQUE KEY `uq_doctor_email` (`email`)
) ENGINE=InnoDB;

-- -----------------------------
-- Table: doctor_specialties
-- Purpose: Many-to-many relationship between doctors and specialties.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `doctor_specialties` (
  `doctor_id` INT UNSIGNED NOT NULL,
  `specialty_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`doctor_id`,`specialty_id`),
  CONSTRAINT `fk_ds_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`doctor_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ds_specialty` FOREIGN KEY (`specialty_id`) REFERENCES `specialties`(`specialty_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------
-- Table: patients
-- Purpose: Stores patient personal information.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `patients` (
  `patient_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(80) NOT NULL,
  `last_name` VARCHAR(80) NOT NULL,
  `email` VARCHAR(255),
  `phone` VARCHAR(30),
  `date_of_birth` DATE,
  `national_id` VARCHAR(50),
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `uq_patient_email` (`email`)
) ENGINE=InnoDB;

-- -----------------------------
-- Table: patient_profiles (One-to-One with patients)
-- Purpose: Optional extended profile for a patient (medical notes, allergies).
-- -----------------------------
CREATE TABLE IF NOT EXISTS `patient_profiles` (
  `patient_id` INT UNSIGNED NOT NULL,
  `emergency_contact_name` VARCHAR(120),
  `emergency_contact_phone` VARCHAR(30),
  `known_allergies` TEXT,
  `medical_history` TEXT,
  PRIMARY KEY (`patient_id`),
  CONSTRAINT `fk_pp_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------
-- Table: rooms
-- Purpose: Physical rooms used for consultations.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `rooms` (
  `room_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `location_description` VARCHAR(255),
  `capacity` SMALLINT UNSIGNED DEFAULT 1,
  PRIMARY KEY (`room_id`),
  UNIQUE KEY `uq_room_name` (`name`)
) ENGINE=InnoDB;

-- -----------------------------
-- Table: services
-- Purpose: Services offered by the clinic (consultation, vaccination, lab test).
-- -----------------------------
CREATE TABLE IF NOT EXISTS `services` (
  `service_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT,
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`service_id`),
  UNIQUE KEY `uq_service_name` (`name`)
) ENGINE=InnoDB;

-- -----------------------------
-- Table: appointments
-- Purpose: Stores appointment bookings between patients and doctors.
-- Notes: start_time & end_time used to define the appointment slot.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `appointments` (
  `appointment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `patient_id` INT UNSIGNED NOT NULL,
  `doctor_id` INT UNSIGNED NOT NULL,
  `room_id` INT UNSIGNED,
  `status` ENUM('scheduled','confirmed','checked_in','in_progress','completed','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `notes` TEXT,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`appointment_id`),
  -- Prevent two appointments for same doctor at the same exact start time
  UNIQUE KEY `uq_doctor_start` (`doctor_id`,`start_time`),
  CONSTRAINT `fk_app_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_app_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_app_room` FOREIGN KEY (`room_id`) REFERENCES `rooms`(`room_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------
-- Table: appointment_services
-- Purpose: Many-to-many between appointments and services (an appointment may include multiple services).
-- -----------------------------
CREATE TABLE IF NOT EXISTS `appointment_services` (
  `appointment_id` INT UNSIGNED NOT NULL,
  `service_id` INT UNSIGNED NOT NULL,
  `quantity` INT UNSIGNED NOT NULL DEFAULT 1,
  `price_at_time` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`appointment_id`,`service_id`),
  CONSTRAINT `fk_as_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_as_service` FOREIGN KEY (`service_id`) REFERENCES `services`(`service_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------
-- Table: payments
-- Purpose: Record payments for appointments or services.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `payments` (
  `payment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `appointment_id` INT UNSIGNED,
  `patient_id` INT UNSIGNED NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `method` ENUM('cash','card','insurance','mobile_money','other') NOT NULL DEFAULT 'cash',
  `status` ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  `paid_at` DATETIME,
  PRIMARY KEY (`payment_id`),
  CONSTRAINT `fk_pay_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`appointment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_pay_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------
-- Table: prescriptions
-- Purpose: Store prescriptions issued after appointments.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `prescriptions` (
  `prescription_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `appointment_id` INT UNSIGNED NOT NULL,
  `doctor_id` INT UNSIGNED NOT NULL,
  `patient_id` INT UNSIGNED NOT NULL,
  `prescribed_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `instructions` TEXT,
  PRIMARY KEY (`prescription_id`),
  CONSTRAINT `fk_pres_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments`(`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pres_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors`(`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pres_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------
-- Table: users (clinic staff / admin)
-- Purpose: Authentication and role management for staff using the system.
-- -----------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(160) NOT NULL,
  `role` ENUM('receptionist','nurse','doctor','admin','lab') NOT NULL DEFAULT 'receptionist',
  `email` VARCHAR(255),
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_user_username` (`username`),
  UNIQUE KEY `uq_user_email` (`email`)
) ENGINE=InnoDB;

-- -----------------------------
-- Optional: Indexes to speed up common queries
-- -----------------------------
CREATE INDEX `idx_appointments_doctor_start` ON `appointments` (`doctor_id`,`start_time`);
CREATE INDEX `idx_appointments_patient` ON `appointments` (`patient_id`);
CREATE INDEX `idx_payments_patient` ON `payments` (`patient_id`);

-- -----------------------------
-- Sample view: patient upcoming appointments
-- Purpose: Convenience view to show upcoming appointments for patients
-- -----------------------------
DROP VIEW IF EXISTS `vw_patient_upcoming_appointments`;
CREATE VIEW `vw_patient_upcoming_appointments` AS
SELECT a.`appointment_id`, a.`patient_id`, p.`first_name` AS patient_first, p.`last_name` AS patient_last,
       a.`doctor_id`, d.`first_name` AS doctor_first, d.`last_name` AS doctor_last,
       a.`start_time`, a.`end_time`, a.`status`, a.`room_id`
FROM `appointments` a
JOIN `patients` p ON a.`patient_id` = p.`patient_id`
JOIN `doctors` d ON a.`doctor_id` = d.`doctor_id`
WHERE a.`start_time` >= NOW();
