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