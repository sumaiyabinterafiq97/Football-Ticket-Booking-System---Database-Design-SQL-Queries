-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Setup
-- DESCRIPTION: DDL Table Creation, Data Seeding & SQL Queries
-- DATABASE: PostgreSQL
-- AUTHOR: Sumaiya Binte Rafiq
-- =========================================================================

-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;


-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
    user_id      INT          NOT NULL,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) NOT NULL,
    role         VARCHAR(20)  NOT NULL,
    phone_number VARCHAR(20),

    -- Primary Key constraint on user_id
    CONSTRAINT pk_users PRIMARY KEY (user_id),

    -- Email must be unique across all users
    CONSTRAINT uq_users_email UNIQUE (email),

    -- Role is restricted to two allowed values
    CONSTRAINT chk_users_role CHECK (role IN ('Ticket Manager', 'Football Fan'))
);


-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
    match_id            INT           NOT NULL,
    fixture             VARCHAR(150)  NOT NULL,
    tournament_category VARCHAR(100)  NOT NULL,
    base_ticket_price   NUMERIC(10,2) NOT NULL,
    match_status        VARCHAR(20)   NOT NULL,

    -- Primary Key constraint on match_id
    CONSTRAINT pk_matches PRIMARY KEY (match_id),

    -- Ticket price must be zero or positive
    CONSTRAINT chk_matches_price CHECK (base_ticket_price >= 0),

    -- Match status restricted to four allowed values
    CONSTRAINT chk_matches_status CHECK (
        match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed')
    )
);


-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
    booking_id     INT           NOT NULL,
    user_id        INT,
    match_id       INT,
    seat_number    VARCHAR(10),
    payment_status VARCHAR(20),
    total_cost     NUMERIC(10,2) NOT NULL,

    -- Primary Key constraint on booking_id
    CONSTRAINT pk_bookings PRIMARY KEY (booking_id),

    -- Foreign Key linking user_id to the Users table
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    -- Foreign Key linking match_id to the Matches table
    CONSTRAINT fk_bookings_match FOREIGN KEY (match_id)
        REFERENCES Matches(match_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    -- Total cost must be zero or positive
    CONSTRAINT chk_bookings_cost CHECK (total_cost >= 0),

    -- Payment status restricted to four allowed values (nullable)
    CONSTRAINT chk_bookings_payment CHECK (
        payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
    )
);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan',   '+8801711111111'),
(2, 'Asif Haque',   'asif@mail.com',   'Football Fan',   '+8801722222222'),
(3, 'Sajjad Rahman','sajjad@mail.com',  'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara',   'jannat@mail.com',  'Football Fan',   NULL);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool',    'Premier League',   120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG',     'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan',  'Serie A',           90.00, 'Sold Out'),
(105, 'Juventus vs Roma',         'Serie A',           80.00, 'Available');


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL,   NULL,        150.00),
(505, 3, 102, 'C-20', 'Pending',   120.00);


-- =========================================================================
-- QUERY 1: Retrieve all upcoming football matches belonging to the
--          'Champions League' where the match status is 'Available'.
-- =========================================================================
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM Matches
WHERE tournament_category = 'Champions League'
  AND match_status = 'Available';

-- Expected Output:
-- match_id | fixture                  | base_ticket_price
-- ---------+--------------------------+------------------
--      101 | Real Madrid vs Barcelona |            150.00
--      103 | Bayern Munich vs PSG     |            130.00


-- =========================================================================
-- QUERY 2: Search for all users whose full names start with 'Tanvir'
--          or contain the phrase 'Haque' (case-insensitive).
-- Concepts: LIKE, ILIKE
-- =========================================================================
SELECT
    user_id,
    full_name,
    email
FROM Users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';

-- Expected Output:
-- user_id | full_name     | email
-- --------+---------------+----------------
--       1 | Tanvir Rahman | tanvir@mail.com
--       2 | Asif Haque    | asif@mail.com


-- =========================================================================
-- QUERY 3: Retrieve all booking records where the payment status is
--          missing (NULL), replacing the empty result with 'Action Required'.
-- Concepts: IS NULL, COALESCE
-- =========================================================================
SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM Bookings
WHERE payment_status IS NULL;

-- Expected Output:
-- booking_id | user_id | match_id | systematic_status
-- -----------+---------+----------+------------------
--        504 |       2 |      101 | Action Required


-- =========================================================================
-- QUERY 4: Retrieve match booking details along with the User's full name
--          and the scheduled Match fixture teams.
-- Concepts: INNER JOIN
-- =========================================================================
SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM Bookings b
INNER JOIN Users   u ON b.user_id  = u.user_id
INNER JOIN Matches m ON b.match_id = m.match_id;

-- Expected Output:
-- booking_id | full_name     | fixture                  | total_cost
-- -----------+---------------+--------------------------+-----------
--        501 | Tanvir Rahman | Real Madrid vs Barcelona |     150.00
--        502 | Tanvir Rahman | Man City vs Liverpool    |     120.00
--        503 | Asif Haque    | Real Madrid vs Barcelona |     150.00
--        504 | Asif Haque    | Real Madrid vs Barcelona |     150.00
--        505 | Sajjad Rahman | Man City vs Liverpool    |     120.00