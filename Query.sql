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