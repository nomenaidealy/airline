-- =====================================================
-- DONNÉES DE TEST COMPLETES
-- =====================================================

-- ========================
-- 1. EMPLOYÉS
-- ========================
INSERT INTO employees (username, password, full_name, role) VALUES
('admin', 'admin123', 'Administrateur Système', 'admin'),
('staff1', 'staff123', 'Andry Razafy', 'staff'),
('compta1', 'compta123', 'Mamy Rasoanaivo', 'accountant');

-- ========================
-- 2. AÉROPORTS
-- ========================
INSERT INTO airports (code, name, city, country) VALUES
('TNR', 'Ivato International Airport', 'Antananarivo', 'Madagascar'),
('CDG', 'Charles de Gaulle Airport', 'Paris', 'France'),
('RUN', 'Roland Garros Airport', 'Saint-Denis', 'Réunion'),
('JNB', 'OR Tambo International Airport', 'Johannesburg', 'South Africa'),
('NBE', 'Fascene Airport', 'Nosy Be', 'Madagascar');

-- ========================
-- 3. AVIONS
-- ========================
INSERT INTO aircrafts (registration, model, total_seats) VALUES
('5R-MDA', 'Airbus A320', 180),
('5R-MDB', 'Boeing 737-800', 162),
('5R-EAA', 'ATR 72-500', 70);

-- ========================
-- 4. CLASSES D’AVION
-- ========================
INSERT INTO aircraft_class (libelle) VALUES
('Economy'),
('Business'),
('First');

-- ========================
-- 5. RÉPARTITION DES SIÈGES
-- ========================
INSERT INTO aircraft_class_seat (id_aircraft, id_aircraftClass, nombre_seat) VALUES
-- Airbus A320
(1, 1, 150),
(1, 2, 24),
(1, 3, 6),
-- Boeing 737
(2, 1, 138),
(2, 2, 24),
-- ATR 72
(3, 1, 70);

-- ========================
-- 6. LIGNES DE VOL
-- ========================
INSERT INTO flight_routes (flight_number, departure_airport_id, arrival_airport_id) VALUES
('MD101', 1, 2),
('MD102', 2, 1),
('MD201', 1, 4),
('MD301', 1, 3),
('MD401', 1, 5);

-- ========================
-- 7. VOLS (flight_instances)
-- ========================
INSERT INTO flight_instances
(route_id, aircraft_id, departure_time, arrival_time, flight_date, base_price, status)
VALUES
(1, 1, '2026-02-15 08:00', '2026-02-15 18:30', '2026-02-15', 450.00, 'scheduled'),
(1, 2, '2026-02-15 20:00', '2026-02-16 06:30', '2026-02-15', 480.00, 'scheduled'),
(2, 1, '2026-02-20 20:00', '2026-02-21 06:30', '2026-02-20', 480.00, 'scheduled'),
(3, 3, '2026-02-10 10:30', '2026-02-10 14:00', '2026-02-10', 220.00, 'scheduled'),
(4, 3, '2026-02-12 07:45', '2026-02-12 09:15', '2026-02-12', 150.00, 'scheduled'),
(5, 1, '2026-01-12 12:00', '2026-01-12 13:30', '2026-01-12', 120.00, 'scheduled');

-- ========================
-- 8. PRIX PAR CLASSE & VOL
-- ========================
INSERT INTO flight_seat_price (id_aircraftClassSeat, id_flight_instance, prix_base) VALUES
-- Vol 1 (A320)
(1, 1, 450.00),
(2, 1, 900.00),
(3, 1, 1500.00),

-- Vol 2 (B737)
(4, 2, 480.00),
(5, 2, 950.00),

-- Vol 3 (A320)
(1, 3, 480.00),
(2, 3, 920.00),
(3, 3, 1480.00),

-- Vol 4 (ATR)
(6, 4, 220.00),

-- Vol 5 (ATR)
(6, 5, 150.00),

-- Vol 6 (A320)
(1, 6, 120.00),
(2, 6, 250.00),
(3, 6, 400.00);

-- ========================
-- 9. PASSAGERS
-- ========================
INSERT INTO passengers
(first_name, last_name, email, phone, passport_number, date_of_birth)
VALUES
('John', 'Doe', 'john.doe@example.com', '0341234567', 'AB123456', '1990-05-15');

-- ========================
-- 10. RÉSERVATIONS
-- ========================
INSERT INTO bookings
(booking_reference, flight_instance_id, passenger_id, seat_number, total_amount, status)
VALUES
('BKG001', 6, 1, '1A', 120.00, 'confirmed');

-- ========================
-- 11. PAIEMENTS
-- ========================
INSERT INTO payments
(booking_id, amount, payment_method, status)
VALUES
(1, 120.00, 'card', 'paid');




INSERT INTO society (libelle)
VALUES
('Vaniala'),
('Lexis');


INSERT INTO diffusion_price (montant, date_debut)
VALUES (400000, '2000-01-01');


INSERT INTO diffusion (
    society_id,
    diffusion_date,
    nombre_diffusion,
    diffusion_price_id
)
VALUES
(1, '2025-12-15', 20, 1),  -- Vaniala
(2, '2025-12-20', 10, 1);  -- Lexis



SELECT
    SUM(d.nombre_diffusion * p.montant) AS ca_decembre_2025
FROM diffusion d
JOIN diffusion_price p ON p.id = d.diffusion_price_id
WHERE d.diffusion_date BETWEEN '2025-12-01' AND '2025-12-31';


SELECT
    s.libelle,
    SUM(d.nombre_diffusion * p.montant) AS chiffre_affaire
FROM diffusion d
JOIN society s ON s.id = d.society_id
JOIN diffusion_price p ON p.id = d.diffusion_price_id
WHERE d.diffusion_date BETWEEN '2025-12-01' AND '2025-12-31'
GROUP BY s.libelle;
