-- 1. Create Tables
CREATE TABLE Customer(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    First_name TEXT NOT NULL,
    Last_name TEXT NOT NULL,
    Email TEXT NOT NULL,
    Is_So_Cal_resident INTEGER NOT NULL,
    Address_id INTEGER NOT NULL REFERENCES Address(Address_id)
);

CREATE TABLE Address(
    Address_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Street1 TEXT NOT NULL,
    Street2 TEXT,
    City TEXT NOT NULL,
    State TEXT NOT NULL,
    Zip TEXT NOT NULL
);

CREATE TABLE Admission(
    Admission_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Type TEXT NOT NULL,
    Issue_date DATE NOT NULL,
    Is_active INTEGER NOT NULL DEFAULT 1,
    Expiration_date DATE NOT NULL
);

CREATE TABLE Ticket(
    Admission_id INTEGER NOT NULL REFERENCES Admission(Admission_id),
    Days_remaining INTEGER NOT NULL,
    Purchaser_id INTEGER NOT NULL REFERENCES Customer(id),
    Ticket_type_id INTEGER NOT NULL REFERENCES Ticket_type(Type_id),
    PRIMARY KEY(Admission_id)
);

CREATE TABLE Season_pass(
    Admission_id INTEGER NOT NULL REFERENCES Admission(Admission_id),
    CustomerId INTEGER NOT NULL REFERENCES Customer(id),
    Type_code TEXT NOT NULL REFERENCES Pass_type(Type_code),
    PRIMARY KEY(Admission_id)
);

CREATE TABLE Pass_type(
    Type_code TEXT NOT NULL,
    Type_name TEXT NOT NULL,
    PRIMARY KEY(Type_code)
);

CREATE TABLE Blackout_rules(
    Rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Type_code TEXT NOT NULL REFERENCES Pass_type(Type_code),
    Start_date DATE NOT NULL,
    End_date DATE NOT NULL
);

CREATE TABLE Ticket_type(
    Type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Type_name TEXT NOT NULL,
    Allowed_visits INTEGER NOT NULL,
    Valid_window_size INTEGER NOT NULL
);

CREATE TABLE Park(
    Park_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Park_name TEXT NOT NULL
);

CREATE TABLE Park_ticket(
    Ticket_type_id INTEGER NOT NULL REFERENCES Ticket_type(Type_id),
    Park_id INTEGER NOT NULL REFERENCES Park(Park_id),
    PRIMARY KEY (Ticket_type_id, Park_id)
);

CREATE TABLE Reservation(
    Reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Park_id INTEGER NOT NULL REFERENCES Park(Park_id),
    Admission_id INTEGER NOT NULL REFERENCES Admission(Admission_id),
    Reservation_date DATE NOT NULL
);
