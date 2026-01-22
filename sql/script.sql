-- =====================================================
-- 1. EMPLOYÉS
-- =====================================================
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'staff',
    CONSTRAINT employee_role_check
        CHECK (role IN ('admin', 'staff', 'accountant'))
);

-- =====================================================
-- 2. AÉROPORTS
-- =====================================================
CREATE TABLE airports (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100)
);

-- =====================================================
-- 3. AVIONS
-- =====================================================
CREATE TABLE aircrafts (
    id SERIAL PRIMARY KEY,
    registration VARCHAR(20) UNIQUE NOT NULL,
    model VARCHAR(50) NOT NULL,
    total_seats INT NOT NULL,
    CONSTRAINT aircraft_seat_check
        CHECK (total_seats > 0)
);




-- =====================================================
-- 4. CLASSES D’AVION
-- =====================================================
CREATE TABLE aircraft_class (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);

-- =====================================================
-- 5. RÉPARTITION DES SIÈGES PAR AVION ET PAR CLASSE
-- =====================================================
CREATE TABLE aircraft_class_seat (
    id SERIAL PRIMARY KEY,
    id_aircraft INT NOT NULL
        REFERENCES aircrafts(id) ON DELETE CASCADE,
    id_aircraftClass INT NOT NULL
        REFERENCES aircraft_class(id) ON DELETE CASCADE,
    nombre_seat INT NOT NULL,
    CONSTRAINT positive_seat_count
        CHECK (nombre_seat > 0),
    CONSTRAINT unique_class_per_aircraft
        UNIQUE (id_aircraft, id_aircraftClass)
);

-- =====================================================
-- 6. LIGNES DE VOL (ROUTES)
-- =====================================================
CREATE TABLE flight_routes (
    id SERIAL PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL,
    departure_airport_id INT NOT NULL
        REFERENCES airports(id),
    arrival_airport_id INT NOT NULL
        REFERENCES airports(id),
    CONSTRAINT unique_route
        UNIQUE (flight_number, departure_airport_id, arrival_airport_id),
    CONSTRAINT different_airports
        CHECK (departure_airport_id <> arrival_airport_id)
);

-- =====================================================
-- 7. EXÉCUTIONS DE VOL
-- =====================================================
CREATE TABLE flight_instances (
    id SERIAL PRIMARY KEY,
    route_id INT NOT NULL
        REFERENCES flight_routes(id) ON DELETE CASCADE,
    aircraft_id INT NOT NULL
        REFERENCES aircrafts(id),
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    flight_date DATE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'scheduled',
    CONSTRAINT valid_time
        CHECK (arrival_time > departure_time),
    CONSTRAINT positive_base_price
        CHECK (base_price >= 0),
    CONSTRAINT flight_status_check
        CHECK (status IN ('scheduled', 'delayed', 'cancelled', 'completed')),
    CONSTRAINT flight_date_check
        CHECK (flight_date = DATE(departure_time))
);

-- =====================================================
-- 8. PRIX DES CLASSES PAR VOL
-- =====================================================
CREATE TABLE flight_seat_price (
    id SERIAL PRIMARY KEY,
    id_aircraftClassSeat INT NOT NULL
        REFERENCES aircraft_class_seat(id) ON DELETE CASCADE,
    id_flight_instance INT NOT NULL
        REFERENCES flight_instances(id) ON DELETE CASCADE,
    prix_base DECIMAL(10,2) NOT NULL,
    CONSTRAINT positive_class_price
        CHECK (prix_base > 0),
    CONSTRAINT unique_price_per_class_flight
        UNIQUE (id_aircraftClassSeat, id_flight_instance)
);

-- =====================================================
-- 9. PASSAGERS
-- =====================================================
CREATE TABLE passengers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    passport_number VARCHAR(50) UNIQUE,
    date_of_birth DATE
);

-- =====================================================
-- 10. RÉSERVATIONS
-- =====================================================
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    booking_reference VARCHAR(15) UNIQUE NOT NULL,
    flight_instance_id INT NOT NULL
        REFERENCES flight_instances(id) ON DELETE CASCADE,
    passenger_id INT NOT NULL
        REFERENCES passengers(id) ON DELETE CASCADE,
    seat_number VARCHAR(10) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmed',
    CONSTRAINT positive_booking_amount
        CHECK (total_amount >= 0),
    CONSTRAINT booking_status_check
        CHECK (status IN ('confirmed', 'cancelled')),
    CONSTRAINT seat_format_check
        CHECK (seat_number ~ '^[0-9]{1,2}[A-F]$'),
    CONSTRAINT unique_seat_per_flight_instance
        UNIQUE (flight_instance_id, seat_number),
    CONSTRAINT unique_passenger_per_flight
        UNIQUE (flight_instance_id, passenger_id)
);

-- =====================================================
-- 11. PAIEMENTS
-- =====================================================
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    booking_id INT UNIQUE
        REFERENCES bookings(id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'paid',
    CONSTRAINT positive_payment_amount
        CHECK (amount >= 0),
    CONSTRAINT payment_status_check
        CHECK (status IN ('paid', 'pending', 'failed', 'refunded'))
);

-- =====================================================
-- 12. SOCIETES
-- =====================================================
CREATE TABLE society (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL
);

-- =====================================================
-- 13. PRIX DES DIFFUSIONS (HISTORIQUE)
-- =====================================================
CREATE TABLE diffusion_price (
    id SERIAL PRIMARY KEY,
    montant DECIMAL(10,2) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE,
    CONSTRAINT positive_diffusion_price CHECK (montant > 0),
    CONSTRAINT valid_price_period
        CHECK (date_fin IS NULL OR date_fin >= date_debut)
);

-- =====================================================
-- 14. DIFFUSIONS PUBLICITAIRES
-- =====================================================
CREATE TABLE diffusion (
    id SERIAL PRIMARY KEY,
    society_id INT NOT NULL
        REFERENCES society(id) ON DELETE CASCADE,
    flight_instance_id INT
        REFERENCES flight_instances(id) ON DELETE SET NULL,
    diffusion_date DATE NOT NULL,
    nombre_diffusion INT NOT NULL,
    diffusion_price_id INT NOT NULL
        REFERENCES diffusion_price(id),
    CONSTRAINT positive_diffusion CHECK (nombre_diffusion > 0)
);

-- =====================================================
-- 15. PAIEMENTS DES SOCIETES
-- =====================================================
CREATE TABLE paiement_societe (
    id SERIAL PRIMARY KEY,
    diffusion_id INT NOT NULL
        REFERENCES diffusion(id) ON DELETE CASCADE,
    montant_total DECIMAL(12,2) NOT NULL, -- montant total à payer pour cette diffusion
    CONSTRAINT positive_total_payment CHECK (montant_total >= 0)
);

-- Détails des paiements partiels effectués par les sociétés
CREATE TABLE paiement_societe_detail (
    id SERIAL PRIMARY KEY,
    paiement_societe_id INT NOT NULL
        REFERENCES paiement_societe(id) ON DELETE CASCADE,
    date_paiement DATE NOT NULL,
    montant_paye DECIMAL(12,2) NOT NULL,
    CONSTRAINT positive_partial_payment CHECK (montant_paye >= 0)
);

