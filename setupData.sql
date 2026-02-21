-- =============================================
-- 1. Reference Data (Parks, Pass Types, Ticket Types)
-- =============================================

-- Create 2 Parks
INSERT INTO `Park` (`Park_name`) VALUES
('Disneyland Park'),
('Disney California Adventure Park');

-- Create 4 Pass Types (Magic Key tiers)
INSERT INTO `Pass_type` (`Type_code`, `Type_name`) VALUES
('INS', 'Inspire Key'),
('BEL', 'Believe Key'),
('ENC', 'Enchant Key'),
('IMG', 'Imagine Key');

-- Create Ticket Types
INSERT INTO `Ticket_type` (`Type_name`, `Allowed_visits`, `Valid_window_size`) VALUES
('1-Day Regular', 1, 1),
('3-Day Park Hopper', 3, 14),
('5-Day Single Park', 5, 14);

-- Link Ticket Types to Parks (Assuming Park Hopper allows both)
INSERT INTO `Park_ticket` (`Ticket_type_id`, `Park_id`) VALUES
(1, 1), -- 1-Day valid for Disneyland
(2, 1), -- 3-Day valid for Disneyland
(2, 2); -- 3-Day valid for California Adventure

-- =============================================
-- 2. User Data (Addresses & Customers)
-- =============================================

-- Create 5 Addresses
INSERT INTO `Address` (`Street1`, `Street2`, `City`, `State`, `Zip`) VALUES
('123 Main St', NULL, 'Anaheim', 'CA', '92802'),
('456 Maple Ave', 'Apt 4B', 'Los Angeles', 'CA', '90001'),
('789 Oak Dr', NULL, 'San Diego', 'CA', '92101'),
('101 Pine Ln', NULL, 'Las Vegas', 'NV', '89101'),
('202 Cedar Blvd', NULL, 'Phoenix', 'AZ', '85001');

-- Create 5 Customers
-- Note: Address_ids are 1-5 based on previous insert
INSERT INTO `Customer` (`First_name`, `Last_name`, `Email`, `Is_So_Cal_resident`, `Address_id`) VALUES
('Mickey', 'Mouse', 'mickey@disney.com', 1, 1), -- SoCal Resident
('Donald', 'Duck', 'donald@disney.com', 1, 2), -- SoCal Resident
('Goofy', 'Goof', 'goofy@disney.com', 1, 3), -- SoCal Resident
('Minnie', 'Mouse', 'minnie@disney.com', 0, 4), -- Out of state
('Daisy', 'Duck', 'daisy@disney.com', 0, 5); -- Out of state

-- =============================================
-- 3. Admissions (The Super-Type Table)
-- =============================================

-- We create 5 Admissions first.
-- IDs will likely be 1, 2, 3, 4, 5.
-- 1, 2, 5 will be Tickets. 3, 4 will be Season Passes.
INSERT INTO `Admission` (`Type`, `Issue_date`, `Is_active`, `Expiration_date`) VALUES
('Ticket', '2023-10-01', 1, '2023-12-31'),       -- ID 1
('Ticket', '2023-10-05', 1, '2023-10-20'),       -- ID 2
('SeasonPass', '2023-01-01', 1, '2024-01-01'),   -- ID 3
('SeasonPass', '2023-06-15', 1, '2024-06-15'),   -- ID 4
('Ticket', '2023-11-01', 1, '2023-11-05');       -- ID 5

-- =============================================
-- 4. Admission Sub-Types (Tickets & Season Passes)
-- =============================================

-- Create Tickets (Linking Admission_id 1, 2, 5)
-- Purchaser_id corresponds to Customers 4 and 5 (Out of state visitors usually buy tickets)
INSERT INTO `Ticket` (`Admission_id`, `Days_remaining`, `Purchaser_id`, `Ticket_type_id`) VALUES
(1, 1, 4, 1), -- Minnie bought a 1-Day ticket
(2, 3, 5, 2), -- Daisy bought a 3-Day Hopper
(5, 1, 4, 1); -- Minnie bought another 1-Day ticket

-- Create Season Passes (Linking Admission_id 3, 4)
-- Corresponds to Customers 1 and 2 (SoCal residents)
INSERT INTO `Season_pass` (`Admission_id`, `CustomerId`, `Type_code`) VALUES
(3, 1, 'INS'), -- Mickey has an Inspire Key
(4, 2, 'IMG'); -- Donald has an Imagine Key

-- =============================================
-- 5. Operations (Reservations & Rules)
-- =============================================

-- Create Blackout Rules
INSERT INTO `Blackout_rules` (`Type_code`, `Start_date`, `End_date`) VALUES
('IMG', '2023-12-20', '2024-01-05'), -- Imagine Key blocked out for Christmas
('ENC', '2023-07-04', '2023-07-04'); -- Enchant Key blocked out for July 4th

-- Create Reservations
-- Park_id 1 = Disneyland, 2 = California Adventure
INSERT INTO `Reservation` (`Park_id`, `Admission_id`, `Reservation_date`) VALUES
(1, 3, '2023-10-31'), -- Mickey (Pass) at Disneyland for Halloween
(2, 4, '2023-11-15'), -- Donald (Pass) at DCA
(1, 2, '2023-10-06'); -- Daisy (Ticket) at Disneyland
