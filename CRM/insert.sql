-- ================================================================
-- SAMPLE DATA - All tables except users
-- Run after schema and users have been created
-- ================================================================

USE crm_db;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================================
-- CLEAR DATA (in FK order)
-- ================================================================
TRUNCATE TABLE invoice_items;
TRUNCATE TABLE invoices;
TRUNCATE TABLE payments;
TRUNCATE TABLE service_request_equipment;
TRUNCATE TABLE service_requests;
TRUNCATE TABLE contract_equipment;
TRUNCATE TABLE contracts;
TRUNCATE TABLE customer_equipment;
TRUNCATE TABLE chat_messages;
TRUNCATE TABLE inventory_transactions;
TRUNCATE TABLE part_units;
TRUNCATE TABLE part_types;
TRUNCATE TABLE equipment_units;
TRUNCATE TABLE equipment_types;
TRUNCATE TABLE categories;

SET FOREIGN_KEY_CHECKS = 1;

-- Reset auto increment
ALTER TABLE categories              AUTO_INCREMENT = 1;
ALTER TABLE part_types              AUTO_INCREMENT = 1;
ALTER TABLE part_units              AUTO_INCREMENT = 1;
ALTER TABLE equipment_types         AUTO_INCREMENT = 1;
ALTER TABLE equipment_units         AUTO_INCREMENT = 1;
ALTER TABLE customer_equipment      AUTO_INCREMENT = 1;
ALTER TABLE contracts               AUTO_INCREMENT = 1;
ALTER TABLE contract_equipment      AUTO_INCREMENT = 1;
ALTER TABLE service_requests        AUTO_INCREMENT = 1;
ALTER TABLE service_request_equipment AUTO_INCREMENT = 1;
ALTER TABLE invoices                AUTO_INCREMENT = 1;
ALTER TABLE invoice_items           AUTO_INCREMENT = 1;
ALTER TABLE payments                AUTO_INCREMENT = 1;
ALTER TABLE inventory_transactions  AUTO_INCREMENT = 1;
ALTER TABLE chat_messages           AUTO_INCREMENT = 1;

-- ================================================================
-- 1. CATEGORIES
-- ================================================================
INSERT INTO categories (name, type) VALUES
('HVAC Components',        'PART'),
('Pump Components',        'PART'),
('Electrical Components',  'PART'),
('Mechanical Parts',       'PART'),
('HVAC System',            'EQUIPMENT'),
('Power System',           'EQUIPMENT'),
('Industrial Pump',        'EQUIPMENT'),
('Air Conditioning Unit',  'EQUIPMENT'),
('Fire Protection System', 'EQUIPMENT'),
('Control System',         'EQUIPMENT');

-- ================================================================
-- 2. PART_TYPES
-- ================================================================
INSERT INTO part_types (name, category_id, description, unit_price, updated_by) VALUES
('Air Filter HEPA',       1, 'High efficiency air filter for HVAC system',          22100000, 6),
('Compressor Motor',      1, '3HP compressor motor for AC unit',                   117000000, 6),
('Evaporator Coil',       1, 'Copper evaporator coil for cooling',                  83200000, 6),
('Condenser Fan Blade',   1, 'Metal fan blade for condenser unit',                  17680000, 6),
('Thermostat Controller', 1, 'Digital thermostat for temperature control',          32500000, 6),
('Pump Impeller',         2, 'Stainless steel impeller for water pump',             54600000, 6),
('Mechanical Seal',       2, 'High-pressure mechanical seal for pump',              23140000, 6),
('Pump Motor Bearing',    2, 'Heavy duty bearing for pump motor',                   14560000, 6),
('Pressure Gauge',        2, 'Digital pressure gauge 0-10 bar',                    11700000, 6),
('Check Valve',           2, 'Non-return valve for water system',                  18720000, 6),
('Circuit Breaker 3P',    3, '3-phase circuit breaker 100A',                        8900000, 6),
('Contactor 40A',         3, 'Magnetic contactor for motor control',                3200000, 6),
('V-Belt Drive',          4, 'Industrial V-belt for fan/pump drive',                1850000, 6),
('Shaft Coupling',        4, 'Flexible shaft coupling for pump',                    9600000, 6);


-- ================================================================
-- 3. PART_UNITS
-- ================================================================
INSERT INTO part_units (part_type_id, status) VALUES
-- Air Filter HEPA (type 1): 8 units
(1,'AVAILABLE'),(1,'AVAILABLE'),(1,'AVAILABLE'),(1,'AVAILABLE'),
(1,'AVAILABLE'),(1,'INUSE'),(1,'AVAILABLE'),(1,'AVAILABLE'),
-- Compressor Motor (type 2): 4 units
(2,'AVAILABLE'),(2,'AVAILABLE'),(2,'AVAILABLE'),(2,'FAULTY'),
-- Evaporator Coil (type 3): 5 units
(3,'AVAILABLE'),(3,'AVAILABLE'),(3,'AVAILABLE'),(3,'AVAILABLE'),(3,'FAULTY'),
-- Condenser Fan Blade (type 4): 10 units
(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),
(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'RETIRED'),
-- Thermostat Controller (type 5): 6 units
(5,'AVAILABLE'),(5,'AVAILABLE'),(5,'AVAILABLE'),(5,'AVAILABLE'),(5,'INUSE'),(5,'AVAILABLE'),
-- Pump Impeller (type 6): 5 units
(6,'AVAILABLE'),(6,'AVAILABLE'),(6,'AVAILABLE'),(6,'AVAILABLE'),(6,'AVAILABLE'),
-- Mechanical Seal (type 7): 8 units
(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),
(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),
-- Pump Motor Bearing (type 8): 10 units
(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),
(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),
-- Pressure Gauge (type 9): 4 units
(9,'AVAILABLE'),(9,'AVAILABLE'),(9,'AVAILABLE'),(9,'AVAILABLE'),
-- Check Valve (type 10): 6 units
(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE'),
-- Circuit Breaker 3P (type 11): 5 units
(11,'AVAILABLE'),(11,'AVAILABLE'),(11,'AVAILABLE'),(11,'INUSE'),(11,'AVAILABLE'),
-- Contactor 40A (type 12): 6 units
(12,'AVAILABLE'),(12,'AVAILABLE'),(12,'AVAILABLE'),(12,'AVAILABLE'),(12,'AVAILABLE'),(12,'FAULTY'),
-- V-Belt Drive (type 13): 8 units
(13,'AVAILABLE'),(13,'AVAILABLE'),(13,'AVAILABLE'),(13,'AVAILABLE'),
(13,'AVAILABLE'),(13,'AVAILABLE'),(13,'AVAILABLE'),(13,'AVAILABLE'),
-- Shaft Coupling (type 14): 4 units
(14,'AVAILABLE'),(14,'AVAILABLE'),(14,'AVAILABLE'),(14,'AVAILABLE');

-- ================================================================
-- 4. EQUIPMENT_TYPES
-- ================================================================
INSERT INTO equipment_types (model, category_id, description, unit_price, updated_by) VALUES
('Daikin VRV IV',         8,  'Central VRV IV air conditioner - 20HP',              285000000, 6),
('Carrier 30XA',          5,  'Central chiller air conditioning system 200RT',      520000000, 6),
('BAC Cooling Tower',     5,  'Cooling tower 500 RT',                               430000000, 6),
('ABB ACH580',            6,  'Variable frequency drive for water pump 15kW',        95000000, 6),
('APC Symmetra 20KVA',    6,  'Building UPS system 20KVA',                          175000000, 6),
('Cummins C150D5',        6,  'Backup generator 150KVA',                            380000000, 6),
('Grundfos CR32-4',       7,  'Domestic water pump for floors 1-10',                 87000000, 6),
('Ebara 3M 32-160',       7,  'Fire fighting pump 37kW',                             92000000, 6),
('Hochiki Fire Panel',    9,  'Central fire alarm panel 256 zones',                  63000000, 6),
('Honeywell Pro-Watch',   10, 'Access control system 64 doors',                     145000000, 6),
('Daikin FXSQ50',         8,  'Ceiling cassette FCU 2HP',                            42000000, 6),
('Grundfos NB65-200',     7,  'Chilled water circulation pump 11kW',                 65000000, 6),
('Schneider Galaxy 3500', 6,  '3-phase UPS 80KVA',                                  420000000, 6),
('Siemens S7-1200',       10, 'PLC for BMS control system',                          38000000, 6);

-- ================================================================
-- 5. EQUIPMENT_UNITS
-- ================================================================
INSERT INTO equipment_units (equipment_type_id, serial_number, status) VALUES
-- Daikin VRV IV (type 1)
(1,'DAI-VRV4-001','AVAILABLE'),
(1,'DAI-VRV4-002','INUSE'),
(1,'DAI-VRV4-003','AVAILABLE'),
(1,'DAI-VRV4-004','INUSE'),
-- Carrier 30XA (type 2)
(2,'CAR-30XA-001','AVAILABLE'),
(2,'CAR-30XA-002','FAULTY'),
-- BAC Cooling Tower (type 3)
(3,'BAC-CT-001','AVAILABLE'),
(3,'BAC-CT-002','AVAILABLE'),
(3,'BAC-CT-003','INUSE'),
-- ABB ACH580 (type 4)
(4,'ABB-ACH-001','AVAILABLE'),
(4,'ABB-ACH-002','INUSE'),
(4,'ABB-ACH-003','AVAILABLE'),
-- APC Symmetra (type 5)
(5,'APC-SYM-001','AVAILABLE'),
(5,'APC-SYM-002','INUSE'),
-- Cummins (type 6)
(6,'CUM-C150-001','AVAILABLE'),
(6,'CUM-C150-002','RETIRED'),
-- Grundfos CR32-4 (type 7)
(7,'GRU-CR32-001','AVAILABLE'),
(7,'GRU-CR32-002','INUSE'),
(7,'GRU-CR32-003','AVAILABLE'),
-- Ebara (type 8)
(8,'EBA-3M-001','AVAILABLE'),
(8,'EBA-3M-002','AVAILABLE'),
-- Hochiki (type 9)
(9,'HOC-FP-001','AVAILABLE'),
(9,'HOC-FP-002','AVAILABLE'),
(9,'HOC-FP-003','INUSE'),
-- Honeywell (type 10)
(10,'HON-PW-001','INUSE'),
(10,'HON-PW-002','AVAILABLE'),
-- Daikin FXSQ50 (type 11)
(11,'DAI-FCU-001','INUSE'),
(11,'DAI-FCU-002','INUSE'),
(11,'DAI-FCU-003','AVAILABLE'),
(11,'DAI-FCU-004','AVAILABLE'),
(11,'DAI-FCU-005','INUSE'),
-- Grundfos NB (type 12)
(12,'GRU-NB-001','AVAILABLE'),
(12,'GRU-NB-002','INUSE'),
-- Schneider Galaxy (type 13)
(13,'SCH-GAL-001','AVAILABLE'),
-- Siemens S7 (type 14)
(14,'SIE-S71-001','INUSE'),
(14,'SIE-S71-002','AVAILABLE');

-- ================================================================
-- 6. CUSTOMER_EQUIPMENT
-- customer id=5 (Pham Thi Customer)
-- customer id=7 (Nguyen Van Binh - customer2)
-- ================================================================
INSERT INTO customer_equipment (customer_id, equipment_unit_id, source, purchased_date, warranty_expires, notes) VALUES
-- customer 5 - INTERNAL
(5, 2,  'INTERNAL', '2022-01-15', '2024-01-15', 'Daikin VRV IV - warranty expired'),
(5, 11, 'INTERNAL', '2022-03-20', '2024-03-20', 'ABB ACH580 - warranty expired'),
(5, 17, 'INTERNAL', '2024-06-01', '2026-06-01', 'Grundfos CR32 - under warranty'),
(5, 22, 'INTERNAL', '2024-09-10', '2026-09-10', 'Hochiki Fire Panel - under warranty'),
(5, 14, 'INTERNAL', '2023-05-20', '2025-05-20', 'APC Symmetra - warranty expires May 2025'),
(5, 27, 'INTERNAL', '2024-11-01', '2026-11-01', 'Daikin FCU-001 - under warranty'),
-- customer 5 - EXTERNAL
(5, NULL, 'EXTERNAL', '2021-05-01', '2023-05-01', 'Purchased at electronics retail store - warranty expired'),
(5, NULL, 'EXTERNAL', '2020-08-15', NULL,         'Old generator - no warranty'),

-- customer 7 (Nguyen Van Binh) - INTERNAL
(7, 4,  'INTERNAL', '2023-02-10', '2025-02-10', 'Daikin VRV IV-004 - warranty expired Feb 2025'),
(7, 19, 'INTERNAL', '2024-01-05', '2026-01-05', 'Grundfos CR32-003 - under warranty'),
(7, 23, 'INTERNAL', '2024-03-15', '2026-03-15', 'Hochiki FP-002 - under warranty'),
(7, 26, 'INTERNAL', '2023-07-20', '2025-07-20', 'Honeywell Pro-Watch - warranty expires Jul 2025'),
-- customer 7 - EXTERNAL
(7, NULL, 'EXTERNAL', '2021-12-01', '2023-12-01', 'Old Toshiba air conditioner - warranty expired'),
(7, NULL, 'EXTERNAL', '2022-06-10', '2024-06-10', 'Pentax water pump - warranty expired');

-- Set name and serial for EXTERNAL equipment
UPDATE customer_equipment SET custom_name='Panasonic 2HP Air Conditioner',  custom_serial='PAN-CS-001'  WHERE id=7;
UPDATE customer_equipment SET custom_name='Honda 5kW Generator',            custom_serial='HON-GEN-001' WHERE id=8;
UPDATE customer_equipment SET custom_name='Toshiba 2.5HP Air Conditioner',  custom_serial='TOS-AC-001'  WHERE id=13;
UPDATE customer_equipment SET custom_name='Pentax CM50 Water Pump',         custom_serial='PEN-CM-001'  WHERE id=14;

-- ================================================================
-- 7. CONTRACTS
-- ================================================================
INSERT INTO contracts (contract_code, customer_id, created_by, contract_type, start_date, end_date, status, notes) VALUES
-- Customer 5 contracts
('CT2025-001', 5, 3, 'MAINTENANCE', '2025-01-01', '2025-12-31', 'ACTIVE',    'Maintenance contract for equipment with expired warranty - 2025 package'),
('CT2025-002', 5, 3, 'WARRANTY',    '2025-01-01', '2026-11-01', 'ACTIVE',    'Warranty contract for equipment still under warranty'),
('CT2024-001', 5, 3, 'MAINTENANCE', '2024-01-01', '2024-12-31', 'EXPIRED',   'Maintenance contract 2024 - expired'),
-- Customer 7 contracts
('CT2025-003', 7, 3, 'MAINTENANCE', '2025-03-01', '2026-02-28', 'ACTIVE',    'Maintenance contract for expired warranty equipment of Nguyen Van Binh'),
('CT2025-004', 7, 3, 'WARRANTY',    '2025-03-01', '2026-03-15', 'ACTIVE',    'Warranty contract for in-warranty equipment of Nguyen Van Binh'),
('CT2024-002', 7, 3, 'MAINTENANCE', '2024-06-01', '2024-12-31', 'CANCELLED', 'Contract cancelled upon customer request');

-- ================================================================
-- 8. CONTRACT_EQUIPMENT
-- contracts: CT2025-001=7, CT2025-002=8, CT2024-001=9, CT2025-003=10, CT2025-004=11, CT2024-002=12
-- ================================================================
-- ================================================================
-- 8. CONTRACT_EQUIPMENT
-- contracts: CT2025-001=1, CT2025-002=2, CT2024-001=3, CT2025-003=4, CT2025-004=5, CT2024-002=6
-- ================================================================

-- CT2025-001 (id=1) MAINTENANCE: expired warranty equipment of customer 5
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(1, 1),  -- Daikin VRV IV (warranty expired 2024)
(1, 2),  -- ABB ACH580 (warranty expired 2024)
(1, 5),  -- APC Symmetra (warranty expires May 2025)
(1, 7),  -- Panasonic external (warranty expired 2023)
(1, 8);  -- Honda generator external (no warranty)

-- CT2025-002 (id=2) WARRANTY: in-warranty equipment of customer 5
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(2, 3),  -- Grundfos CR32 (under warranty until 2026)
(2, 4),  -- Hochiki Fire Panel (under warranty until 2026)
(2, 6);  -- Daikin FCU-001 (under warranty until 2026)

-- CT2024-001 (id=3) EXPIRED: maintenance 2024 of customer 5
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(3, 1),
(3, 2);

-- CT2025-003 (id=4) MAINTENANCE: expired warranty equipment of customer 7
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(4, 9),   -- Daikin VRV IV-004 (warranty expired Feb 2025)
(4, 12),  -- Honeywell (warranty expires Jul 2025)
(4, 13),  -- Toshiba external (warranty expired 2023)
(4, 14);  -- Pentax external (warranty expired 2024)

-- CT2025-004 (id=5) WARRANTY: in-warranty equipment of customer 7
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(5, 10),  -- Grundfos CR32-003 (under warranty until 2026)
(5, 11);  -- Hochiki FP-002 (under warranty until 2026)

-- CT2024-002 (id=6) CANCELLED
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(6, 9),
(6, 13);
-- ================================================================
-- 9. SERVICE_REQUESTS
-- contracts: CT2025-001=1, CT2025-002=2, CT2024-001=3, CT2025-003=4, CT2025-004=5, CT2024-002=6
-- ================================================================
INSERT INTO service_requests (request_code, customer_id, contract_id, title, description, priority, status, reviewed_by, reviewed_at, reject_reason, assigned_to, assigned_at, completed_at) VALUES
('SR2025-001', 5, 1,  'Daikin air conditioner not cooling',
 'Daikin VRV IV is not functioning properly and cannot reach the set temperature. Power supply has been checked and is normal.',
 'HIGH', 'IN_PROGRESS', 2, '2026-01-16 09:00:00', NULL, 4, '2026-01-17 08:00:00', NULL),

('SR2025-002', 5, 1,  'Scheduled maintenance for APC UPS',
 'Request for 6-month periodic maintenance of APC Symmetra 20KVA UPS. Battery inspection, connection check, and load test required.',
 'MEDIUM', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL),

('SR2025-003', 5, 1,  'Scheduled maintenance for ABB ACH580',
 'Request for periodic maintenance of ABB variable frequency drive as per schedule. Parameter check, filter cleaning, and firmware update required.',
 'LOW', 'COMPLETED', 2, '2026-02-01 09:00:00', NULL, 4, '2026-02-02 08:00:00', '2026-02-05 16:00:00'),

('SR2025-004', 5, 1,  'Panasonic air conditioner refrigerant leak',
 'Panasonic 2HP air conditioner suspected refrigerant leak, poor cooling performance and unusual noise from compressor.',
 'HIGH', 'APPROVED', 2, '2026-02-10 10:00:00', NULL, NULL, NULL, NULL),

('SR2025-005', 5, 1,  'Honda generator inspection',
 'Honda 5kW generator will not start, fuel system and battery need to be inspected.',
 'URGENT', 'REJECTED', 2, '2026-02-15 11:00:00', 'Equipment is not covered under this maintenance contract. A separate contract is required.', NULL, NULL, NULL),

('SR2025-006', 5, 2,  'Grundfos pump making unusual noise',
 'Grundfos CR32-4 pump emits a strange noise during operation, suspected worn bearing or impeller issue.',
 'MEDIUM', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL),

('SR2025-007', 5, 2,  'Hochiki false fire alarm',
 'Hochiki fire alarm panel continuously triggers false alarms at zone 5. Has been reset multiple times but the issue persists.',
 'HIGH', 'IN_PROGRESS', 2, '2026-03-01 08:30:00', NULL, 4, '2026-03-02 09:00:00', NULL),

('SR2026-001', 5, 2,  'Scheduled maintenance for Daikin FCU',
 'Daikin FXSQ50 FCU requires periodic maintenance: filter cleaning, drain pan inspection, and operational testing.',
 'LOW', 'COMPLETED', 2, '2026-03-05 09:00:00', NULL, 4, '2026-03-06 08:00:00', '2026-03-07 15:00:00'),

('SR2025-008', 7, 4,  'Daikin VRV floor 3 no cooling',
 'Daikin VRV IV system on floor 3 is not operating. Error code E7 detected on indoor unit.',
 'HIGH', 'IN_PROGRESS', 2, '2026-02-20 10:00:00', NULL, 4, '2026-02-21 08:00:00', NULL),

('SR2025-009', 7, 4,  'Honeywell access control fault',
 'Honeywell Pro-Watch access control system is not reading cards at floor 1 and floor 2 entry doors.',
 'MEDIUM', 'APPROVED', 2, '2026-02-25 14:00:00', NULL, NULL, NULL, NULL),

('SR2025-010', 7, 4,  'Pentax pump low pressure',
 'Pentax CM50 water pump is running but not reaching required pressure, suspected worn impeller.',
 'MEDIUM', 'COMPLETED', 2, '2026-01-10 09:00:00', NULL, 4, '2026-01-11 08:00:00', '2026-01-15 17:00:00'),

('SR2026-002', 7, 5,  'Grundfos NB excessive vibration',
 'Grundfos CR32-003 pump vibrates excessively when running at high speed, dynamic balancing inspection required.',
 'HIGH', 'PENDING', NULL, NULL, NULL, NULL, NULL, NULL),

('SR2026-003', 7, 5,  'Hochiki zone 8 offline',
 'Fire alarm zone 8 is offline on Hochiki FP-002 central panel, unable to connect to detector.',
 'HIGH', 'APPROVED', 2, '2026-03-08 10:00:00', NULL, NULL, NULL, NULL);

-- ================================================================
-- 10. SERVICE_REQUEST_EQUIPMENT
-- ================================================================
INSERT INTO service_request_equipment (service_request_id, customer_equipment_id, issue_description) VALUES
-- SR2025-001: Daikin not cooling
(1, 1, 'Cannot reach set temperature, possible refrigerant leak or compressor failure'),
-- SR2025-002: APC UPS maintenance
(2, 5, 'Periodic maintenance - battery capacity check and load test'),
-- SR2025-003: ABB maintenance
(3, 2, '6-month periodic maintenance - completed'),
-- SR2025-004: Panasonic refrigerant leak
(4, 7, 'Refrigerant leak - poor cooling, unusual noise from compressor'),
-- SR2025-005: Honda generator
(5, 8, 'Will not start'),
-- SR2025-006: Grundfos unusual noise
(6, 3, 'Unusual noise, suspected worn bearing or impeller issue'),
-- SR2025-007: Hochiki false alarm
(7, 4, 'False alarm at zone 5, reset multiple times with no resolution'),
-- SR2026-001: FCU maintenance
(8, 6, 'Periodic maintenance - filter cleaning, drain pan inspection'),
-- SR2025-008: Daikin customer 7
(9, 9, 'Error E7 on indoor unit, no cooling'),
-- SR2025-009: Honeywell
(10, 12, 'Card reader not responding at floor 1 and floor 2 entry doors'),
-- SR2025-010: Pentax
(11, 14, 'Unable to reach required pressure, suspected worn impeller - resolved'),
-- SR2026-002: Grundfos vibration
(12, 10, 'Excessive vibration at high speed, dynamic balancing inspection required'),
-- SR2026-003: Hochiki zone 8
(13, 11, 'Zone 8 offline, unable to connect detector');

-- ================================================================
-- 11. INVOICES
-- service_request ids: SR2025-001=1, SR2025-003=3, SR2025-007=7, SR2026-001=8, SR2025-009=10, SR2025-010=11
-- ================================================================
INSERT INTO invoices (invoice_code, customer_id, service_request_id, invoice_type, subtotal, tax_percent, tax_amount, total_amount, status, due_date, notes, created_by) VALUES
('INV2025-001', 5, 3,  'REPAIR', 3500000, 10.00,  350000,  3850000, 'PAID',      '2026-02-28', 'ABB ACH580 maintenance - paid',              3),
('INV2025-002', 5, 1,  'REPAIR', 8500000, 10.00,  850000,  9350000, 'UNPAID',    '2026-04-17', 'Daikin VRV IV repair - in progress',          3),
('INV2025-003', 5, 7,  'REPAIR', 4200000, 10.00,  420000,  4620000, 'UNPAID',    '2026-04-01', 'Hochiki false alarm repair',                  3),
('INV2025-004', 5, 8,  'REPAIR', 1500000, 10.00,  150000,  1650000, 'PAID',      '2026-03-31', 'Daikin FCU maintenance - paid',               3),
('INV2025-005', 7, 11, 'REPAIR', 6800000, 10.00,  680000,  7480000, 'PAID',      '2026-02-15', 'Pentax CM50 pump repair - paid',              3),
('INV2025-006', 7, 10, 'REPAIR', 3200000, 10.00,  320000,  3520000, 'UNPAID',    '2026-03-25', 'Honeywell access control repair',             3),
('INV2026-001', 5, 3,  'REPAIR', 2000000, 10.00,  200000,  2200000, 'CANCELLED', '2026-01-31', 'Invoice cancelled - replaced by INV2025-001', 3);

-- ================================================================
-- 12. INVOICE_ITEMS
-- ================================================================
INSERT INTO invoice_items (invoice_id, item_name, item_type, quantity, unit_price, total_price) VALUES
-- INV2025-001: ABB maintenance
(1, 'Periodic maintenance ABB ACH580 - inspection & cleaning', 'SERVICE', 1, 1500000, 1500000),
(1, 'Replacement dust filter',                                 'PART',    2,  450000,  900000),
(1, 'Technician labor (4 hours)',                              'SERVICE', 4,  275000, 1100000),
-- INV2025-002: Daikin repair
(2, 'R410A refrigerant recharge',                              'SERVICE', 1, 2500000, 2500000),
(2, 'Control board inspection and cleaning',                   'SERVICE', 1, 1800000, 1800000),
(2, 'Technician labor (8 hours)',                              'SERVICE', 8,  275000, 2200000),
(2, 'Miscellaneous parts',                                     'OTHER',   1,  200000,  200000),
-- INV2025-003: Hochiki
(3, 'Zone 5 detector inspection and replacement',              'PART',    2,  850000, 1700000),
(3, 'Central panel reprogramming',                             'SERVICE', 1,  900000,  900000),
(3, 'Technician labor (4 hours)',                              'SERVICE', 4,  400000, 1600000),
-- INV2025-004: Daikin FCU
(4, 'Ceiling cassette FCU cleaning',                           'SERVICE', 1,  800000,  800000),
(4, 'FCU filter replacement',                                  'PART',    1,  350000,  350000),
(4, 'Technician labor (2 hours)',                              'SERVICE', 2,  175000,  350000),
-- INV2025-005: Pentax
(5, 'Pentax CM50 pump impeller replacement',                   'PART',    1, 3200000, 3200000),
(5, 'Mechanical seal replacement',                             'PART',    1,  850000,  850000),
(5, 'Technician labor (6 hours)',                              'SERVICE', 6,  450000, 2750000),
-- INV2025-006: Honeywell
(6, 'Floor 1-2 card reader inspection and reconfiguration',    'SERVICE', 1, 1200000, 1200000),
(6, 'Floor 1 card reader replacement',                         'PART',    1, 1500000, 1500000),
(6, 'Technician labor (3 hours)',                              'SERVICE', 3,  165000,  500000);

-- ================================================================
-- 13. PAYMENTS
-- ================================================================
INSERT INTO payments (payment_code, invoice_id, customer_id, amount, payment_method, status, transaction_ref, note) VALUES
('PAY2025-001', 1, 5, 3850000, 'VNPAY', 'SUCCESS', 'VNP20250205123456', 'Paid via VNPay'),
('PAY2025-002', 4, 5, 1650000, 'CASH',  'SUCCESS', NULL,                'Cash payment at office'),
('PAY2025-003', 5, 7, 7480000, 'VNPAY', 'SUCCESS', 'VNP20250115987654', 'Paid via VNPay'),
('PAY2025-004', 2, 5, 9350000, 'VNPAY', 'PENDING', NULL,                'Awaiting payment confirmation'),
('PAY2025-005', 3, 5, 4620000, 'CASH',  'PENDING', NULL,                'Awaiting cash collection');

-- ================================================================
-- 14. INVENTORY_TRANSACTIONS
-- ================================================================
INSERT INTO inventory_transactions (item_type, item_unit_id, action, transaction_type, performed_by, customer_name, order_code, note) VALUES
('EQUIPMENT', 2,  'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2022-001', 'Sold Daikin VRV IV-002'),
('EQUIPMENT', 11, 'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2022-002', 'Sold ABB ACH580-002'),
('EQUIPMENT', 17, 'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2024-001', 'Sold Grundfos CR32-001'),
('EQUIPMENT', 22, 'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2024-002', 'Sold Hochiki FP-001'),
('EQUIPMENT', 14, 'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2023-001', 'Sold APC Symmetra-002'),
('EQUIPMENT', 27, 'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2024-003', 'Sold Daikin FCU-001'),
('EQUIPMENT', 4,  'EXPORT_SALE', 'PURCHASE', 5, 'Nguyen Van Binh',   'ORD-2023-002', 'Sold Daikin VRV IV-004'),
('EQUIPMENT', 19, 'EXPORT_SALE', 'PURCHASE', 5, 'Nguyen Van Binh',   'ORD-2024-004', 'Sold Grundfos CR32-003'),
('EQUIPMENT', 23, 'EXPORT_SALE', 'PURCHASE', 5, 'Nguyen Van Binh',   'ORD-2024-005', 'Sold Hochiki FP-002'),
('EQUIPMENT', 26, 'EXPORT_SALE', 'PURCHASE', 5, 'Nguyen Van Binh',   'ORD-2023-003', 'Sold Honeywell Pro-Watch-002');

INSERT INTO inventory_transactions (item_type, item_unit_id, action, transaction_type, performed_by, ref_order_id, note) VALUES
('PART', 6,  'EXPORT_REPAIR', 'REPAIR', 6, 3,  'Picked up Air Filter for ABB maintenance SR'),
('PART', 31, 'EXPORT_REPAIR', 'REPAIR', 6, 1,  'Picked up Circuit Breaker for Daikin VRV repair'),
('PART', 27, 'EXPORT_REPAIR', 'REPAIR', 6, 11, 'Picked up Pump Impeller for Pentax repair'),
('PART', 33, 'EXPORT_REPAIR', 'REPAIR', 6, 11, 'Picked up Mechanical Seal for Pentax repair');

-- ================================================================
-- 15. CHAT_MESSAGES
-- ================================================================
INSERT INTO chat_messages (sender_id, receiver_id, message, is_read) VALUES
-- customer 5 <-> supporter (id=3)
(5, 3, 'Hello, I need assistance with registering a maintenance contract.', 1),
(3, 5, 'Hello! I can assist you right away. Which equipment do you need maintenance for?', 1),
(5, 3, 'I have a Daikin VRV IV air conditioner and an ABB variable frequency drive, both warranties have expired.', 1),
(3, 5, 'I have created maintenance contract CT2025-001 for those two devices. Please review the details.', 1),
(5, 3, 'Thank you! I have received the contract information.', 1),
(5, 3, 'My Daikin unit is broken and not cooling. I need urgent assistance!', 1),
(3, 5, 'SR2025-001 has been created for you. I will prioritize this and have it handled today.', 1),
(5, 3, 'Has the technician arrived yet?', 0),

-- customer 7 <-> supporter (id=3)
(7, 3, 'Hello, I would like to inquire about a warranty contract for my equipment.', 1),
(3, 7, 'Hello Nguyen Van Binh! I can assist you. Which equipment do you need covered under warranty?', 1),
(7, 3, 'I have a Grundfos pump and a Hochiki fire alarm panel purchased last year, both still under warranty.', 1),
(3, 7, 'Could you please provide the serial numbers for both devices?', 1),
(7, 3, 'GRU-CR32-003 and HOC-FP-002', 1),
(3, 7, 'I have created warranty contract CT2025-004 for those two devices. Please review it!', 0),

-- customer 5 <-> supporter (id=3) - invoice inquiry
(5, 3, 'Hello, I would like to ask about invoice INV2025-002.', 1),
(3, 5, 'Hello! Invoice INV2025-002 is currently UNPAID. You may settle it via VNPay or cash payment.', 0);

-- Parts
UPDATE part_types SET image_url = '/uploads/parts/air-filter.webp' WHERE id = 1;
UPDATE part_types SET image_url = '/uploads/parts/check-value.webp' WHERE id = 10;
UPDATE part_types SET image_url = '/uploads/parts/Circuit-Breaker-3P.jpg' WHERE id = 11;
UPDATE part_types SET image_url = '/uploads/parts/Compressor Motor.webp' WHERE id = 2;
UPDATE part_types SET image_url = '/uploads/parts/Condenser Fan Blade.webp' WHERE id = 4;
UPDATE part_types SET image_url = '/uploads/parts/Contactor 40A.webp' WHERE id = 12;
UPDATE part_types SET image_url = '/uploads/parts/Evaporator Coil.webp' WHERE id = 3;
UPDATE part_types SET image_url = '/uploads/parts/Mechanical Seal.webp' WHERE id = 7;
UPDATE part_types SET image_url = '/uploads/parts/OIP.jpg' WHERE id = 9;
UPDATE part_types SET image_url = '/uploads/parts/Pump Impeller.avif' WHERE id = 6;
UPDATE part_types SET image_url = '/uploads/parts/Pump Motor Bearing.webp' WHERE id = 8;
UPDATE part_types SET image_url = '/uploads/parts/Shaft Coupling.jpg' WHERE id = 14;
UPDATE part_types SET image_url = '/uploads/parts/Thermostat Controller.jpg' WHERE id = 5;
UPDATE part_types SET image_url = '/uploads/parts/V-Belt Drive.jpg' WHERE id = 13;

-- Equipment
UPDATE equipment_types SET image_url = '/uploads/equipment/ACH580-01-044A-4.jpg' WHERE id = 4;
UPDATE equipment_types SET image_url = '/uploads/equipment/R.jpg' WHERE id = 5;
UPDATE equipment_types SET image_url = '/uploads/equipment/OIP.jpg' WHERE id = 3;
UPDATE equipment_types SET image_url = '/uploads/equipment/carrier-30xa-air-cooled-chiller-B.avif' WHERE id = 2;
UPDATE equipment_types SET image_url = '/uploads/equipment/Cummins C150D5.jpg' WHERE id = 6;
UPDATE equipment_types SET image_url = '/uploads/equipment/OIP.webp' WHERE id =11;
UPDATE equipment_types SET image_url = '/uploads/equipment/Daikin VRV IV.webp' WHERE id = 1;
UPDATE equipment_types SET image_url = '/uploads/equipment/Ebara 3M 32-160.webp' WHERE id = 8;
UPDATE equipment_types SET image_url = '/uploads/equipment/Grundfos CR32-4.webp' WHERE id = 7;
UPDATE equipment_types SET image_url = '/uploads/equipment/Grundfos NB65-200.webp' WHERE id = 12;
UPDATE equipment_types SET image_url = '/uploads/equipment/Hochiki Fire Panel.webp' WHERE id = 9;
UPDATE equipment_types SET image_url = '/uploads/equipment/honeywell_pro-watch_tablet.png' WHERE id = 10;
UPDATE equipment_types SET image_url = '/uploads/equipment/Schneider Galaxy 3500.webp' WHERE id = 13;
UPDATE equipment_types SET image_url = '/uploads/equipment/Siemens S7-1200.jpg' WHERE id = 14;

UPDATE users SET
    address_street   = '01 Đường Sao Mai',
    address_ward     = 'Phường Ánh Dương',
    address_district = 'Quận Bình Minh',
    address_city     = 'Hà Nội',
    address_full     = '01 Đường Sao Mai, Phường Ánh Dương, Quận Bình Minh, Hà Nội',
    hometown         = 'Ninh Bình',
    date_of_birth    = '1992-03-10',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH Sao Mai Tech',
    emergency_name   = 'Nguyễn Thị Lan',
    emergency_phone  = '0900000001',
    emergency_relation = 'Mẹ',
    bio              = 'Kỹ thuật viên hệ thống điện cơ bản.'
WHERE id = 1;

UPDATE users SET
    address_street   = '22 Đường Hòa Bình',
    address_ward     = 'Phường Thanh Xuân',
    address_district = 'Quận Trung Tâm',
    address_city     = 'Hà Nội',
    address_full     = '22 Đường Hòa Bình, Phường Thanh Xuân, Quận Trung Tâm, Hà Nội',
    hometown         = 'Hà Nam',
    date_of_birth    = '1991-07-21',
    gender           = 'FEMALE',
    company_name     = 'Công ty CP Hòa Bình Group',
    emergency_name   = 'Trần Văn Nam',
    emergency_phone  = '0900000002',
    emergency_relation = 'Anh',
    bio              = 'Chuyên viên quản lý thiết bị văn phòng.'
WHERE id = 2;

UPDATE users SET
    address_street   = '15 Đường Mặt Trời',
    address_ward     = 'Phường Bình An',
    address_district = 'Quận Đông Thành',
    address_city     = 'Hà Nội',
    address_full     = '15 Đường Mặt Trời, Phường Bình An, Quận Đông Thành, Hà Nội',
    hometown         = 'Thái Bình',
    date_of_birth    = '1993-11-05',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH Sunrise Tech',
    emergency_name   = 'Lê Thị Hoa',
    emergency_phone  = '0900000003',
    emergency_relation = 'Chị',
    bio              = 'Kỹ sư bảo trì hệ thống điện lạnh.'
WHERE id = 3;

UPDATE users SET
    address_street   = '88 Đường Gió Nam',
    address_ward     = 'Phường Tân Phong',
    address_district = 'Quận Nam Thành',
    address_city     = 'Hà Nội',
    address_full     = '88 Đường Gió Nam, Phường Tân Phong, Quận Nam Thành, Hà Nội',
    hometown         = 'Thanh Hóa',
    date_of_birth    = '1989-01-18',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH Gió Nam Solutions',
    emergency_name   = 'Phạm Thị Mai',
    emergency_phone  = '0900000004',
    emergency_relation = 'Vợ',
    bio              = 'Quản lý vận hành hệ thống cơ điện.'
WHERE id = 4;

UPDATE users SET
    address_street   = '77 Đường Ánh Trăng',
    address_ward     = 'Phường Minh Khai',
    address_district = 'Quận Bắc Thành',
    address_city     = 'Hà Nội',
    address_full     = '77 Đường Ánh Trăng, Phường Minh Khai, Quận Bắc Thành, Hà Nội',
    hometown         = 'Hải Dương',
    date_of_birth    = '1994-09-30',
    gender           = 'FEMALE',
    company_name     = 'Công ty CP Moonlight Tech',
    emergency_name   = 'Nguyễn Văn Bình',
    emergency_phone  = '0900000005',
    emergency_relation = 'Bố',
    bio              = 'Chuyên viên hỗ trợ kỹ thuật thiết bị.'
WHERE id = 5;

UPDATE users SET
    address_street   = '09 Đường Cầu Vồng',
    address_ward     = 'Phường Hòa Lạc',
    address_district = 'Quận Tây Thành',
    address_city     = 'Hà Nội',
    address_full     = '09 Đường Cầu Vồng, Phường Hòa Lạc, Quận Tây Thành, Hà Nội',
    hometown         = 'Nam Định',
    date_of_birth    = '1990-12-12',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH Rainbow Systems',
    emergency_name   = 'Đỗ Thị Hạnh',
    emergency_phone  = '0900000006',
    emergency_relation = 'Mẹ',
    bio              = 'Nhân viên kỹ thuật bảo trì thiết bị.'
WHERE id = 6;

UPDATE users SET
    address_street   = '33 Đường Bình Minh',
    address_ward     = 'Phường Tân An',
    address_district = 'Quận Nam Trung',
    address_city     = 'Hà Nội',
    address_full     = '33 Đường Bình Minh, Phường Tân An, Quận Nam Trung, Hà Nội',
    hometown         = 'Hưng Yên',
    date_of_birth    = '1995-06-25',
    gender           = 'FEMALE',
    company_name     = 'Công ty TNHH Bình Minh Tech',
    emergency_name   = 'Lê Văn Hùng',
    emergency_phone  = '0900000007',
    emergency_relation = 'Anh',
    bio              = 'Chuyên viên quản lý hệ thống kỹ thuật.'
WHERE id = 7;

UPDATE users SET
    address_street   = '55 Đường Đại Dương',
    address_ward     = 'Phường Hải An',
    address_district = 'Quận Đông Hải',
    address_city     = 'Hà Nội',
    address_full     = '55 Đường Đại Dương, Phường Hải An, Quận Đông Hải, Hà Nội',
    hometown         = 'Quảng Ninh',
    date_of_birth    = '1996-02-14',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH Ocean Tech',
    emergency_name   = 'Trần Thị Nga',
    emergency_phone  = '0900000008',
    emergency_relation = 'Chị',
    bio              = 'Kỹ thuật viên hệ thống làm lạnh.'
WHERE id = 8;

UPDATE users SET
    address_street   = '11 Đường Hoa Sen',
    address_ward     = 'Phường Thanh Bình',
    address_district = 'Quận Nam Hải',
    address_city     = 'Hà Nội',
    address_full     = '11 Đường Hoa Sen, Phường Thanh Bình, Quận Nam Hải, Hà Nội',
    hometown         = 'Bắc Ninh',
    date_of_birth    = '1992-08-12',
    gender           = 'FEMALE',
    company_name     = 'Công ty TNHH Hoa Sen Tech',
    emergency_name   = 'Nguyễn Văn Dũng',
    emergency_phone  = '0910000009',
    emergency_relation = 'Anh',
    bio              = 'Nhân viên quản lý thiết bị văn phòng.'
WHERE id = 9;

UPDATE users SET
    address_street   = '66 Đường Mây Trắng',
    address_ward     = 'Phường Hòa Phát',
    address_district = 'Quận Bắc Hải',
    address_city     = 'Hà Nội',
    address_full     = '66 Đường Mây Trắng, Phường Hòa Phát, Quận Bắc Hải, Hà Nội',
    hometown         = 'Vĩnh Phúc',
    date_of_birth    = '1991-04-03',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH CloudTech',
    emergency_name   = 'Trần Thị Hạnh',
    emergency_phone  = '0910000010',
    emergency_relation = 'Mẹ',
    bio              = 'Kỹ thuật viên hệ thống điện lạnh.'
WHERE id = 10;

UPDATE users SET
    address_street   = '27 Đường Ánh Sao',
    address_ward     = 'Phường Minh Tân',
    address_district = 'Quận Đông Hải',
    address_city     = 'Hà Nội',
    address_full     = '27 Đường Ánh Sao, Phường Minh Tân, Quận Đông Hải, Hà Nội',
    hometown         = 'Hải Phòng',
    date_of_birth    = '1993-10-19',
    gender           = 'MALE',
    company_name     = 'Công ty CP StarTech',
    emergency_name   = 'Lê Văn Sơn',
    emergency_phone  = '0910000011',
    emergency_relation = 'Bố',
    bio              = 'Chuyên viên bảo trì hệ thống cơ điện.'
WHERE id = 11;

UPDATE users SET
    address_street   = '45 Đường Gió Bắc',
    address_ward     = 'Phường Tân Bình',
    address_district = 'Quận Trung Hải',
    address_city     = 'Hà Nội',
    address_full     = '45 Đường Gió Bắc, Phường Tân Bình, Quận Trung Hải, Hà Nội',
    hometown         = 'Thái Nguyên',
    date_of_birth    = '1988-12-01',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH WindTech',
    emergency_name   = 'Phạm Thị Lan',
    emergency_phone  = '0910000012',
    emergency_relation = 'Vợ',
    bio              = 'Quản lý vận hành hệ thống kỹ thuật tòa nhà.'
WHERE id = 12;

UPDATE users SET
    address_street   = '90 Đường Bình Yên',
    address_ward     = 'Phường An Hòa',
    address_district = 'Quận Tây Hải',
    address_city     = 'Hà Nội',
    address_full     = '90 Đường Bình Yên, Phường An Hòa, Quận Tây Hải, Hà Nội',
    hometown         = 'Quảng Bình',
    date_of_birth    = '1995-02-22',
    gender           = 'FEMALE',
    company_name     = 'Công ty TNHH PeaceTech',
    emergency_name   = 'Nguyễn Thị Thu',
    emergency_phone  = '0910000013',
    emergency_relation = 'Chị',
    bio              = 'Nhân viên hỗ trợ kỹ thuật.'
WHERE id = 13;

UPDATE users SET
    address_street   = '13 Đường Đại Lộ Xanh',
    address_ward     = 'Phường Phú Mỹ',
    address_district = 'Quận Nam Trung',
    address_city     = 'Hà Nội',
    address_full     = '13 Đường Đại Lộ Xanh, Phường Phú Mỹ, Quận Nam Trung, Hà Nội',
    hometown         = 'Đà Nẵng',
    date_of_birth    = '1990-06-14',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH GreenTech',
    emergency_name   = 'Đỗ Văn Long',
    emergency_phone  = '0910000014',
    emergency_relation = 'Anh',
    bio              = 'Kỹ sư hệ thống điện công nghiệp.'
WHERE id = 14;

UPDATE users SET
    address_street   = '72 Đường Hoàng Hôn',
    address_ward     = 'Phường Hồng Hà',
    address_district = 'Quận Bắc Trung',
    address_city     = 'Hà Nội',
    address_full     = '72 Đường Hoàng Hôn, Phường Hồng Hà, Quận Bắc Trung, Hà Nội',
    hometown         = 'Huế',
    date_of_birth    = '1994-11-09',
    gender           = 'FEMALE',
    company_name     = 'Công ty TNHH Sunset Tech',
    emergency_name   = 'Trần Văn Hải',
    emergency_phone  = '0910000015',
    emergency_relation = 'Bố',
    bio              = 'Chuyên viên quản lý thiết bị kỹ thuật.'
WHERE id = 15;

UPDATE users SET
    address_street   = '05 Đường Bình Minh',
    address_ward     = 'Phường Đông Sơn',
    address_district = 'Quận Nam Thành',
    address_city     = 'Hà Nội',
    address_full     = '05 Đường Bình Minh, Phường Đông Sơn, Quận Nam Thành, Hà Nội',
    hometown         = 'Lào Cai',
    date_of_birth    = '1996-01-27',
    gender           = 'MALE',
    company_name     = 'Công ty TNHH Sunrise Systems',
    emergency_name   = 'Lê Thị Mai',
    emergency_phone  = '0910000016',
    emergency_relation = 'Mẹ',
    bio              = 'Nhân viên kỹ thuật bảo trì hệ thống.'
WHERE id = 16;

UPDATE users SET avatar_url = '/uploads/avatar/beluga-beluga-cat-meme.gif' WHERE id = 1;
UPDATE users SET avatar_url = '/uploads/avatar/chó.webp' WHERE id = 2;
UPDATE users SET avatar_url = '/uploads/avatar/mèo.webp' WHERE id = 3;
UPDATE users SET avatar_url = '/uploads/avatar/khoc.webp' WHERE id = 4;
UPDATE users SET avatar_url = '/uploads/avatar/meo1.webp' WHERE id = 5;
UPDATE users SET avatar_url = '/uploads/avatar/ngua.webp' WHERE id = 6;
UPDATE users SET avatar_url = '/uploads/avatar/OIP.webp' WHERE id = 7;
UPDATE users SET avatar_url = '/uploads/avatar/vit.webp' WHERE id = 8;