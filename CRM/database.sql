CREATE DATABASE IF NOT EXISTS crm_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE crm_db;

-- Bảng roles
CREATE TABLE IF NOT EXISTS roles (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (name) VALUES
    ('ADMIN'),
    ('CUSTOMER'),
    ('CUSTOMER_SUPPORT'),
    ('TECHNICAL_MANAGER'),
    ('STOREKEEPER'),
    ('TECHNICIAN');

-- Bảng users
CREATE TABLE IF NOT EXISTS users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(150)  NOT NULL,
    email         VARCHAR(255)  UNIQUE,
    phone         VARCHAR(20),
    username      VARCHAR(100)  UNIQUE,
    password      VARCHAR(255),
    auth_provider ENUM('LOCAL','GOOGLE','FACEBOOK') NOT NULL DEFAULT 'LOCAL',
    provider_id   VARCHAR(255),
    avatar_url    TEXT,
    role_id       INT           NOT NULL DEFAULT 2,
    active        TINYINT(1)    NOT NULL DEFAULT 1,
    created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    INDEX idx_username (username),
    INDEX idx_email    (email),
    INDEX idx_provider (auth_provider, provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data (password = "123456" BCrypt)
INSERT INTO users (full_name, email, phone, username, password, auth_provider, role_id, active) VALUES
('System Administrator', 'admin@drsms.local',       '0123456789', 'admin',       '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 1, 1),
('Nguyen Van Technical',  'techmanager@drsms.local', '0123456780', 'techmanager', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 4, 1),
('Tran Thi Support',      'support@drsms.local',     '0123456781', 'supporter',   '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 3, 1),
('Le Van Technician',     'technician@drsms.local',  '0123456782', 'technician',  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 6, 1),
('Pham Thi Customer',     'customer@drsms.local',    '0123456783', 'customer',    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 2, 1),
('Hoang Van Storekeeper', 'storekeeper@drsms.local', '0123456784', 'storekeeper', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 5, 1);


-- -----------------------------------------------
-- 1. CATEGORIES (dùng chung cho Part & Equipment)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    type       ENUM('PART','EQUIPMENT','BOTH') NOT NULL DEFAULT 'BOTH',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO categories (name, type) VALUES
('HVAC Components',       'PART'),
('Pump Components',       'PART'),
('Electrical Components', 'PART'),
('Mechanical Parts',      'PART'),
('HVAC System',           'EQUIPMENT'),
('Power System',          'EQUIPMENT'),
('Industrial Pump',       'EQUIPMENT'),
('Air Conditioning Unit', 'EQUIPMENT'),
('Fire Protection System','EQUIPMENT'),
('Control System',        'EQUIPMENT');

-- -----------------------------------------------
-- 2. PART_TYPES (loại linh kiện - master data)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS part_types (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    description VARCHAR(255),
    unit_price  DECIMAL(15,2) NOT NULL DEFAULT 0,
    updated_by  INT,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (updated_by)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 3. PART_UNITS (từng unit linh kiện cụ thể)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS part_units (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    part_type_id INT NOT NULL,
    status       ENUM('AVAILABLE','INUSE','FAULTY','RETIRED') NOT NULL DEFAULT 'AVAILABLE',
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (part_type_id) REFERENCES part_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 4. EQUIPMENT_TYPES (loại thiết bị - master data)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS equipment_types (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    model       VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    description VARCHAR(255),
    unit_price  DECIMAL(15,2) NOT NULL DEFAULT 0,
    updated_by  INT,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (updated_by)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 5. EQUIPMENT_UNITS (từng thiết bị có serial number)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS equipment_units (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    equipment_type_id INT NOT NULL,
    serial_number     VARCHAR(100) NOT NULL UNIQUE,
    status            ENUM('AVAILABLE','INUSE','FAULTY','RETIRED') NOT NULL DEFAULT 'AVAILABLE',
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------
-- 6. INVENTORY_TRANSACTIONS (lịch sử xuất/nhập kho)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    item_type    ENUM('PART','EQUIPMENT') NOT NULL,
    item_unit_id INT NOT NULL,
    action       ENUM('IMPORT','EXPORT_SALE','EXPORT_REPAIR','RETURN','RETIRE') NOT NULL,
    performed_by INT NOT NULL,
    ref_order_id INT DEFAULT NULL,
    note         VARCHAR(255),
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Part Types
INSERT INTO part_types (name, category_id, description, unit_price, updated_by) VALUES
('Air Filter HEPA',       1, 'High efficiency air filter for HVAC system',         22100000, 5),
('Compressor Motor',      1, '3HP compressor motor for AC unit',                  117000000, 5),
('Evaporator Coil',       1, 'Copper evaporator coil for cooling',                 83200000, 5),
('Condenser Fan Blade',   1, 'Metal fan blade for condenser unit',                 17680000, 5),
('Thermostat Controller', 1, 'Digital thermostat for temperature control',         32500000, 5),
('Pump Impeller',         2, 'Stainless steel impeller for water pump',            54600000, 5),
('Mechanical Seal',       2, 'High-pressure mechanical seal for pump',             23140000, 5),
('Pump Motor Bearing',    2, 'Heavy duty bearing for pump motor',                  14560000, 5),
('Pressure Gauge',        2, 'Digital pressure gauge 0-10 bar',                   11700000, 5),
('Check Valve',           2, 'Non-return valve for water system',                  18720000, 5);

-- Part Units (6 units cho Air Filter HEPA: 5 AVAILABLE, 1 INUSE)
INSERT INTO part_units (part_type_id, status) VALUES
(1,'AVAILABLE'),(1,'AVAILABLE'),(1,'AVAILABLE'),(1,'AVAILABLE'),(1,'AVAILABLE'),(1,'INUSE'),
-- Compressor Motor: 3 units
(2,'AVAILABLE'),(2,'AVAILABLE'),(2,'AVAILABLE'),
-- Evaporator Coil: 4 units
(3,'AVAILABLE'),(3,'AVAILABLE'),(3,'AVAILABLE'),(3,'FAULTY'),
-- Condenser Fan Blade: 10 units
(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),
(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'AVAILABLE'),(4,'RETIRED'),
-- Thermostat Controller: 5 units
(5,'AVAILABLE'),(5,'AVAILABLE'),(5,'AVAILABLE'),(5,'AVAILABLE'),(5,'INUSE'),
-- Pump Impeller: 4 units
(6,'AVAILABLE'),(6,'AVAILABLE'),(6,'AVAILABLE'),(6,'AVAILABLE'),
-- Mechanical Seal: 6 units
(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),(7,'AVAILABLE'),
-- Pump Motor Bearing: 8 units
(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),(8,'AVAILABLE'),
-- Pressure Gauge: 3 units
(9,'AVAILABLE'),(9,'AVAILABLE'),(9,'AVAILABLE'),
-- Check Valve: 5 units
(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE'),(10,'AVAILABLE');

-- Equipment Types
INSERT INTO equipment_types (model, category_id, description, unit_price, updated_by) VALUES
('Daikin VRV IV',       8,  'Central air conditioner - Floor 1-5',            285000000, 5),
('Carrier 30XA',        5,  'Central chiller air conditioning system',        520000000, 5),
('BAC Cooling Tower',   5,  'Cooling tower 500 RT',                           430000000, 5),
('ABB ACH580',          6,  'Variable frequency drive for water pump control', 95000000, 5),
('APC Symmetra 20KVA',  6,  'Building UPS system',                            175000000, 5),
('Cummins C150D5',      6,  'Backup generator 150KVA',                        380000000, 5),
('Grundfos CR32-4',     7,  'Domestic water pump for floors 1-10',             87000000, 5),
('Ebara 3M 32-160',     7,  'Fire fighting pump',                              92000000, 5),
('Hochiki Fire Panel',  9,  'Central fire alarm panel',                        63000000, 5),
('Honeywell Pro-Watch', 10, 'Access control system',                          145000000, 5);

-- Equipment Units (có serial number)
INSERT INTO equipment_units (equipment_type_id, serial_number, status) VALUES
(1, 'DAI-VRV4-001', 'AVAILABLE'),
(1, 'DAI-VRV4-002', 'INUSE'),
(1, 'DAI-VRV4-003', 'AVAILABLE'),
(2, 'CAR-30XA-001', 'AVAILABLE'),
(2, 'CAR-30XA-002', 'FAULTY'),
(3, 'BAC-CT-001',   'AVAILABLE'),
(3, 'BAC-CT-002',   'AVAILABLE'),
(4, 'ABB-ACH-001',  'AVAILABLE'),
(4, 'ABB-ACH-002',  'INUSE'),
(5, 'APC-SYM-001',  'AVAILABLE'),
(6, 'CUM-C150-001', 'AVAILABLE'),
(6, 'CUM-C150-002', 'RETIRED'),
(7, 'GRU-CR32-001', 'AVAILABLE'),
(7, 'GRU-CR32-002', 'INUSE'),
(8, 'EBA-3M-001',   'AVAILABLE'),
(9, 'HOC-FP-001',   'AVAILABLE'),
(9, 'HOC-FP-002',   'AVAILABLE'),
(10,'HON-PW-001',   'INUSE'),
(10,'HON-PW-002',   'AVAILABLE');

SET SQL_SAFE_UPDATES = 0;
-- Thêm cột transaction_type để phân biệt mua / sửa chữa
ALTER TABLE inventory_transactions
    ADD COLUMN transaction_type ENUM('PURCHASE','REPAIR','IMPORT','OTHER') NOT NULL DEFAULT 'OTHER' AFTER action,
    ADD COLUMN customer_name    VARCHAR(150) DEFAULT NULL AFTER transaction_type,
    ADD COLUMN order_code       VARCHAR(50)  DEFAULT NULL AFTER customer_name;

-- Cập nhật data mẫu đã có
UPDATE inventory_transactions SET transaction_type = 'IMPORT' WHERE action = 'IMPORT';

-- Sample transactions - PURCHASE
INSERT INTO inventory_transactions (item_type, item_unit_id, action, transaction_type, performed_by, customer_name, order_code, note) VALUES
('PART',      1,  'EXPORT_SALE', 'PURCHASE', 5, 'Pham Thi Customer', 'ORD-2025-001', 'Customer purchased Air Filter HEPA'),
('PART',      7,  'EXPORT_SALE', 'PURCHASE', 5, 'Nguyen Van An',     'ORD-2025-002', 'Customer purchased Mechanical Seal'),
('EQUIPMENT', 2,  'EXPORT_SALE', 'PURCHASE', 5, 'ABC Company',       'ORD-2025-003', 'Sold Daikin VRV IV'),
('PART',      13, 'EXPORT_SALE', 'PURCHASE', 5, 'Tran Thi Bich',     'ORD-2025-004', 'Customer purchased Evaporator Coil'),
('EQUIPMENT', 9,  'EXPORT_SALE', 'PURCHASE', 5, 'XYZ Company',       'ORD-2025-005', 'Sold ABB ACH580');

-- Sample transactions - REPAIR
INSERT INTO inventory_transactions (item_type, item_unit_id, action, transaction_type, performed_by, ref_order_id, note) VALUES
('PART',      6,  'EXPORT_REPAIR', 'REPAIR', 5, 1, 'Technician picked up Pump Impeller for repair'),
('PART',      25, 'EXPORT_REPAIR', 'REPAIR', 5, 1, 'Technician picked up Thermostat for order #1'),
('PART',      28, 'EXPORT_REPAIR', 'REPAIR', 5, 2, 'Technician picked up Pump Impeller for order #2'),
('PART',      3,  'EXPORT_REPAIR', 'REPAIR', 5, 3, 'Technician picked up Evaporator Coil for order #3'),
('EQUIPMENT', 14, 'EXPORT_REPAIR', 'REPAIR', 5, 2, 'Technician picked up Grundfos for order #2');
-- --------------------



-- ================================================================
-- CUSTOMER MODULE - THÊM VÀO DATABASE HIỆN CÓ
-- Chạy file này SAU khi đã có schema gốc
-- ================================================================

-- 1. CUSTOMER_EQUIPMENT
--    Equipment customer sở hữu (mua trong hệ thống hoặc bên ngoài)
-- ================================================================
CREATE TABLE IF NOT EXISTS customer_equipment (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT          NOT NULL,
    equipment_unit_id INT          DEFAULT NULL,   -- NULL nếu mua ngoài hệ thống
    custom_name       VARCHAR(150) DEFAULT NULL,   -- tên tự nhập nếu mua ngoài
    custom_serial     VARCHAR(100) DEFAULT NULL,   -- serial tự nhập nếu mua ngoài
    source            ENUM('INTERNAL','EXTERNAL') NOT NULL DEFAULT 'INTERNAL',
    purchased_date    DATE         DEFAULT NULL,
    warranty_expires  DATE         DEFAULT NULL,   -- ngày hết hạn bảo hành
    notes             VARCHAR(255) DEFAULT NULL,
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id)       REFERENCES users(id),
    FOREIGN KEY (equipment_unit_id) REFERENCES equipment_units(id),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. CONTRACTS
-- ================================================================
CREATE TABLE IF NOT EXISTS contracts (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    contract_code  VARCHAR(20)  NOT NULL UNIQUE,   -- CT2025-001
    customer_id    INT          NOT NULL,
    created_by     INT          NOT NULL,           -- customer_support user
    contract_type  ENUM('WARRANTY','MAINTENANCE') NOT NULL,
    start_date     DATE         NOT NULL,
    end_date       DATE         NOT NULL,
    status         ENUM('ACTIVE','EXPIRED','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    notes          TEXT         DEFAULT NULL,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (created_by)  REFERENCES users(id),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. CONTRACT_EQUIPMENT
--    Nhiều equipment trong 1 contract
-- ================================================================
CREATE TABLE IF NOT EXISTS contract_equipment (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    contract_id            INT NOT NULL,
    customer_equipment_id  INT NOT NULL,
    FOREIGN KEY (contract_id)           REFERENCES contracts(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_equipment_id) REFERENCES customer_equipment(id),
    UNIQUE KEY uk_ce (contract_id, customer_equipment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. SERVICE_REQUESTS
-- ================================================================
CREATE TABLE IF NOT EXISTS service_requests (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    request_code  VARCHAR(20)  NOT NULL UNIQUE,    -- SR2025-001
    customer_id   INT          NOT NULL,
    contract_id   INT          NOT NULL,
    title         VARCHAR(255) NOT NULL,
    description   TEXT         NOT NULL,
    priority      ENUM('LOW','MEDIUM','HIGH','URGENT') NOT NULL DEFAULT 'MEDIUM',
    status        ENUM('PENDING','APPROVED','REJECTED','IN_PROGRESS','COMPLETED','CANCELLED')
                  NOT NULL DEFAULT 'PENDING',
    -- Technical Manager review
    reviewed_by   INT          DEFAULT NULL,
    reviewed_at   TIMESTAMP    NULL,
    reject_reason VARCHAR(255) DEFAULT NULL,
    -- Technician assignment
    assigned_to   INT          DEFAULT NULL,
    assigned_at   TIMESTAMP    NULL,
    completed_at  TIMESTAMP    NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (contract_id) REFERENCES contracts(id),
    FOREIGN KEY (reviewed_by) REFERENCES users(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    INDEX idx_customer (customer_id),
    INDEX idx_status   (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. SERVICE_REQUEST_EQUIPMENT
--    Nhiều equipment trong 1 service request
-- ================================================================
CREATE TABLE IF NOT EXISTS service_request_equipment (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    service_request_id     INT NOT NULL,
    customer_equipment_id  INT NOT NULL,
    issue_description      VARCHAR(255) DEFAULT NULL,  -- mô tả vấn đề của riêng thiết bị này
    FOREIGN KEY (service_request_id)    REFERENCES service_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_equipment_id) REFERENCES customer_equipment(id),
    UNIQUE KEY uk_sre (service_request_id, customer_equipment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. CHAT_MESSAGES
-- ================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT  NOT NULL,
    receiver_id INT  NOT NULL,
    message     TEXT NOT NULL,
    is_read     TINYINT(1) NOT NULL DEFAULT 0,
    created_at  TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id)   REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    INDEX idx_pair (sender_id, receiver_id),
    INDEX idx_unread (receiver_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. INVOICES  (customer chỉ xem, support/technician tạo)
-- ================================================================
CREATE TABLE IF NOT EXISTS invoices (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    invoice_code       VARCHAR(20)  NOT NULL UNIQUE,   -- INV2025-001
    customer_id        INT          NOT NULL,
    service_request_id INT          DEFAULT NULL,
    invoice_type       ENUM('REPAIR','PURCHASE') NOT NULL DEFAULT 'REPAIR',
    subtotal           DECIMAL(15,2) NOT NULL DEFAULT 0,
    tax_percent        DECIMAL(5,2)  NOT NULL DEFAULT 10.00,
    tax_amount         DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount       DECIMAL(15,2) NOT NULL DEFAULT 0,
    status             ENUM('UNPAID','PAID','CANCELLED') NOT NULL DEFAULT 'UNPAID',
    due_date           DATE         DEFAULT NULL,
    notes              TEXT         DEFAULT NULL,
    created_by         INT          NOT NULL,
    created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id)        REFERENCES users(id),
    FOREIGN KEY (service_request_id) REFERENCES service_requests(id),
    FOREIGN KEY (created_by)         REFERENCES users(id),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. INVOICE_ITEMS
-- ================================================================
CREATE TABLE IF NOT EXISTS invoice_items (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id  INT           NOT NULL,
    item_name   VARCHAR(255)  NOT NULL,
    item_type   ENUM('PART','EQUIPMENT','SERVICE','OTHER') NOT NULL DEFAULT 'SERVICE',
    quantity    INT           NOT NULL DEFAULT 1,
    unit_price  DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- SAMPLE DATA
-- ================================================================

-- Additional users
INSERT IGNORE INTO users (full_name, email, phone, username, password, auth_provider, role_id, active) VALUES
('Nguyen Van Binh', 'customer2@drsms.local', '0901234567', 'customer2',  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdFd3dByM0X5pMe', 'LOCAL', 2, 1);

INSERT IGNORE INTO users (full_name, email, phone, username, password, auth_provider, role_id, active) VALUES
('Tran Van Minh',      'customer3@drsms.local', '0912345601', 'customer3', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 2, 1),
('Nguyen Thi Lan',     'customer4@drsms.local', '0912345602', 'customer4', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 2, 1),
('Le Hoang Nam',       'customer5@drsms.local', '0912345603', 'customer5', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 2, 1),
('Pham Thi Huong',     'customer6@drsms.local', '0912345604', 'customer6', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 2, 1),
('Hoang Duc Thanh',    'customer7@drsms.local', '0912345605', 'customer7', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 2, 1);
 
-- ================================================================
-- THÊM 4 TECHNICIANS (role_id = 6)
-- ================================================================
INSERT IGNORE INTO users (full_name, email, phone, username, password, auth_provider, role_id, active) VALUES
('Nguyen Van Khanh',   'technician2@drsms.local', '0923456781', 'technician2', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 6, 1),
('Tran Duc Hieu',      'technician3@drsms.local', '0923456782', 'technician3', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 6, 1),
('Le Van Phong',       'technician4@drsms.local', '0923456783', 'technician4', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 6, 1),
('Pham Quoc Bao',      'technician5@drsms.local', '0923456784', 'technician5', '$2a$12$eUY11RuVC6WvbwSyZac2kuOT/XszxgH1XIs/mQhlyib4TSC7C7TF6', 'LOCAL', 6, 1);
-- Customer equipment (customer id=5 owns the following equipment)
INSERT INTO customer_equipment (customer_id, equipment_unit_id, source, purchased_date, warranty_expires, notes) VALUES
(5, 2,  'INTERNAL', '2022-01-15', '2024-01-15', 'Daikin VRV IV - warranty expired'),
(5, 9,  'INTERNAL', '2022-03-20', '2024-03-20', 'ABB ACH580 - warranty expired'),
(5, 13, 'INTERNAL', '2024-06-01', '2026-06-01', 'Grundfos CR32 - under warranty'),
(5, 16, 'INTERNAL', '2024-09-10', '2026-09-10', 'Hochiki Fire Panel - under warranty');

-- External equipment (purchased outside the system)
INSERT INTO customer_equipment (customer_id, equipment_unit_id, source, custom_name, custom_serial, purchased_date, warranty_expires, notes) VALUES
(5, NULL, 'EXTERNAL', 'Panasonic 2HP Air Conditioner', 'PAN-CS-001', '2021-05-01', '2023-05-01', 'Purchased at electronics retail store');

-- Contracts
INSERT INTO contracts (contract_code, customer_id, created_by, contract_type, start_date, end_date, status, notes) VALUES
('CT2025-001', 5, 3, 'MAINTENANCE', '2025-01-01', '2025-12-31', 'ACTIVE', 'Maintenance contract for equipment with expired warranty'),
('CT2025-002', 5, 3, 'WARRANTY',    '2025-01-01', '2026-06-01', 'ACTIVE', 'Warranty contract for equipment still under warranty');

-- Contract equipment
-- CT2025-001 (MAINTENANCE): Daikin + ABB + Panasonic (warranty expired)
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(1, 1),  -- Daikin VRV IV
(1, 2),  -- ABB ACH580
(1, 5);  -- Panasonic (external)

-- CT2025-002 (WARRANTY): Grundfos + Hochiki (still under warranty)
INSERT INTO contract_equipment (contract_id, customer_equipment_id) VALUES
(2, 3),  -- Grundfos CR32
(2, 4);  -- Hochiki Fire Panel

-- Service Requests
INSERT INTO service_requests (request_code, customer_id, contract_id, title, description, priority, status, reviewed_by, reviewed_at, assigned_to, assigned_at) VALUES
('SR2025-001', 5, 1, 'Daikin air conditioner not cooling',     'Daikin VRV IV is not functioning properly and cannot reach the set temperature. Power supply has been checked and is normal.', 'HIGH',   'IN_PROGRESS', 2, '2025-01-16 09:00:00', 4, '2025-01-17 08:00:00'),
('SR2025-002', 5, 2, 'Grundfos pump making unusual noise',     'The pump emits a strange noise during operation, suspected worn bearing.',                                                       'MEDIUM', 'PENDING',     NULL, NULL, NULL, NULL),
('SR2025-003', 5, 1, 'Scheduled maintenance for ABB ACH580',   'Request for periodic maintenance of ABB variable frequency drive as per schedule.',                                              'LOW',    'COMPLETED',   2, '2025-02-01 09:00:00', 4, '2025-02-02 08:00:00');

-- Service request equipment
INSERT INTO service_request_equipment (service_request_id, customer_equipment_id, issue_description) VALUES
(1, 1, 'Cannot reach target temperature, possible refrigerant leak or compressor failure'),
(2, 3, 'Unusual noise, possible bearing wear'),
(3, 2, '6-month scheduled maintenance');

-- Invoices
INSERT INTO invoices (invoice_code, customer_id, service_request_id, invoice_type, subtotal, tax_percent, tax_amount, total_amount, status, due_date, created_by) VALUES
('INV2025-002', 5, 3, 'REPAIR', 2500000, 10.00, 250000, 2750000, 'UNPAID', '2026-03-31', 3),
('INV2025-001', 5, 3, 'REPAIR', 2500000, 10.00, 250000, 2750000, 'UNPAID', '2025-03-31', 3);

INSERT INTO invoice_items (invoice_id, item_name, item_type, quantity, unit_price, total_price) VALUES
(1, 'Scheduled maintenance ABB ACH580 - inspection & cleaning', 'SERVICE', 1, 1500000, 1500000),
(1, 'Technician labor (4 hours)',                               'SERVICE', 4,  250000, 1000000);

-- Chat messages
INSERT INTO chat_messages (sender_id, receiver_id, message, is_read) VALUES
(5, 3, 'Hello, I need assistance with registering a maintenance contract.', 1),
(3, 5, 'Hello! I can assist you right away. Which equipment do you need maintenance for?', 1),
(5, 3, 'I have a Daikin VRV IV air conditioner and an ABB variable frequency drive, both have expired warranties.', 1),
(3, 5, 'I will create a MAINTENANCE contract for those two devices. Please confirm the serial numbers: DAI-VRV4-002 and ABB-ACH-002 are correct?', 0);


CREATE TABLE IF NOT EXISTS payments (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    payment_code     VARCHAR(30)   NOT NULL UNIQUE,         -- PAY2025-001
    invoice_id       INT           NOT NULL,
    customer_id      INT           NOT NULL,
    amount           DECIMAL(15,2) NOT NULL,
    payment_method   ENUM('CASH','VNPAY') NOT NULL,
    status           ENUM('PENDING','SUCCESS','FAILED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    transaction_ref  VARCHAR(100)  DEFAULT NULL,            -- mã giao dịch VNPay (nếu có)
    note             VARCHAR(255)  DEFAULT NULL,
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id)  REFERENCES invoices(id),
    FOREIGN KEY (customer_id) REFERENCES users(id),
    INDEX idx_invoice  (invoice_id),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


ALTER TABLE part_types      ADD COLUMN image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE equipment_types ADD COLUMN image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE chat_messages
    ADD COLUMN is_recalled TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN is_pinned   TINYINT(1) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS chat_reactions (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id    INT NOT NULL,
    emoji      VARCHAR(10) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (message_id) REFERENCES chat_messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)    REFERENCES users(id),
    UNIQUE KEY uk_reaction (message_id, user_id, emoji)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT          NOT NULL,
    role       ENUM('user','assistant') NOT NULL,
    content    TEXT         NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_time (user_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- MIGRATION: Add Extended Personal Info to Users Table
-- Run this script once on your existing crm_db
-- ================================================================

USE crm_db;

ALTER TABLE users
    -- Địa chỉ thường trú (dùng cho technician tìm đường)
    ADD COLUMN address_street    VARCHAR(255) DEFAULT NULL COMMENT 'Số nhà, tên đường',
    ADD COLUMN address_ward      VARCHAR(100) DEFAULT NULL COMMENT 'Phường / Xã',
    ADD COLUMN address_district  VARCHAR(100) DEFAULT NULL COMMENT 'Quận / Huyện',
    ADD COLUMN address_city      VARCHAR(100) DEFAULT NULL COMMENT 'Tỉnh / Thành phố',
    ADD COLUMN address_full      VARCHAR(500) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ (auto-concat, dùng cho maps)',

    -- Quê quán
    ADD COLUMN hometown          VARCHAR(255) DEFAULT NULL COMMENT 'Quê quán',

    -- Thông tin cá nhân
    ADD COLUMN date_of_birth     DATE         DEFAULT NULL COMMENT 'Ngày sinh',
    ADD COLUMN gender            ENUM('MALE','FEMALE','OTHER') DEFAULT NULL COMMENT 'Giới tính',
    ADD COLUMN national_id       VARCHAR(20)  DEFAULT NULL COMMENT 'Số CCCD / CMND',

    -- Liên hệ khẩn cấp
    ADD COLUMN emergency_name    VARCHAR(150) DEFAULT NULL COMMENT 'Tên người liên hệ khẩn cấp',
    ADD COLUMN emergency_phone   VARCHAR(20)  DEFAULT NULL COMMENT 'SĐT người liên hệ khẩn cấp',
    ADD COLUMN emergency_relation VARCHAR(50) DEFAULT NULL COMMENT 'Quan hệ (vợ/chồng, cha/mẹ...)',

    -- Thông tin nghề nghiệp / bổ sung
    ADD COLUMN company_name      VARCHAR(150) DEFAULT NULL COMMENT 'Tên công ty / tổ chức',
    ADD COLUMN bio               TEXT         DEFAULT NULL COMMENT 'Mô tả bản thân';

-- Index cho tìm kiếm theo thành phố (technician dispatch)
ALTER TABLE users
    ADD INDEX idx_address_city (address_city),
    ADD INDEX idx_address_district (address_district);

UPDATE users SET password = '$2a$12$2DuRJznQjyVCKB5kFHBTCuYV5WWmfrz4UbvCfgAdyaRLrFGrLwTE.' 
WHERE username IN ('admin','techmanager','supporter','technician','customer2','storekeeper','customer');
 
-- ================================================================
-- MIGRATION: Chat features enhancement
-- ================================================================
 
-- 1. Thêm attachment support vào chat_messages
ALTER TABLE chat_messages
    ADD COLUMN attachment_url  VARCHAR(500) DEFAULT NULL COMMENT 'URL file/ảnh đính kèm',
    ADD COLUMN attachment_name VARCHAR(255) DEFAULT NULL COMMENT 'Tên gốc của file',
    ADD COLUMN attachment_type ENUM('IMAGE','FILE') DEFAULT NULL COMMENT 'Loại đính kèm';
 
-- 2. Thêm is_delivered (message status: sent → delivered → read)
ALTER TABLE chat_messages
    ADD COLUMN is_delivered TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = receiver đã nhận được';
 
-- Index để query nhanh hơn
ALTER TABLE chat_messages
    ADD INDEX idx_delivered (receiver_id, is_delivered);
 
-- 3. Bảng user_presence (online/offline)
CREATE TABLE IF NOT EXISTS user_presence (
    user_id    INT PRIMARY KEY,
    last_seen  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_online  TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- 4. Bảng user_typing (typing indicator — TTL ngắn, tự cleanup)
CREATE TABLE IF NOT EXISTS user_typing (
    user_id     INT NOT NULL,
    receiver_id INT NOT NULL,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, receiver_id),
    FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

 ALTER TABLE invoice_items
ADD COLUMN ref_item_id INT DEFAULT NULL COMMENT 'part_type_id hoặc equipment_type_id';

CREATE TABLE IF NOT EXISTS product_reviews (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT          NOT NULL,
    item_type     VARCHAR(20)  NOT NULL,  -- 'PART' hoặc 'EQUIPMENT'
    item_id       INT          NOT NULL,  -- part_type_id hoặc equipment_type_id
    rating        TINYINT      NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    image_url     VARCHAR(500),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id)
);

ALTER TABLE customer_equipment 
ADD COLUMN custom_image_url VARCHAR(500) DEFAULT NULL;
