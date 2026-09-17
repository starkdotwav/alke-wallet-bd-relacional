-- Proyecto: Alke Wallet
-- Módulo: Fundamentos de Bases de Datos Relacionales
-- Motor: MySQL 8

CREATE DATABASE IF NOT EXISTS AlkeWallet;
USE AlkeWallet;

DROP TABLE IF EXISTS transaccion;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS moneda;

CREATE TABLE moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL UNIQUE,
    currency_symbol VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    saldo DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    currency_id INT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_usuario_saldo CHECK (saldo >= 0),
    CONSTRAINT fk_usuario_moneda FOREIGN KEY (currency_id)
        REFERENCES moneda(currency_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    currency_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_transaccion_importe CHECK (amount > 0),
    CONSTRAINT chk_transaccion_usuarios CHECK (sender_user_id <> receiver_user_id),
    CONSTRAINT fk_transaccion_emisor FOREIGN KEY (sender_user_id)
        REFERENCES usuario(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transaccion_receptor FOREIGN KEY (receiver_user_id)
        REFERENCES usuario(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transaccion_moneda FOREIGN KEY (currency_id)
        REFERENCES moneda(currency_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_transaccion_emisor_fecha
    ON transaccion(sender_user_id, transaction_date);

CREATE INDEX idx_transaccion_receptor_fecha
    ON transaccion(receiver_user_id, transaction_date);

-- Datos de prueba
INSERT INTO moneda (currency_name, currency_symbol) VALUES
    ('Peso chileno', 'CLP'),
    ('Dólar estadounidense', 'USD'),
    ('Euro', 'EUR');

INSERT INTO usuario (nombre, email, password_hash, saldo, currency_id) VALUES
    ('Marcel Navarrete', 'marcel@example.com', 'hash_demo_001', 250000.00, 1),
    ('Ana González', 'ana@example.com', 'hash_demo_002', 180000.00, 1),
    ('Carlos Pérez', 'carlos@example.com', 'hash_demo_003', 95000.00, 1),
    ('Sofía Martínez', 'sofia@example.com', 'hash_demo_004', 1200.00, 2);

INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, amount) VALUES
    (1, 2, 1, 25000.00),
    (2, 3, 1, 15000.00),
    (1, 4, 1, 10000.00);

-- Consulta: moneda elegida por un usuario específico
SELECT
    u.user_id,
    u.nombre,
    m.currency_name AS moneda,
    m.currency_symbol AS simbolo
FROM usuario AS u
INNER JOIN moneda AS m ON u.currency_id = m.currency_id
WHERE u.user_id = 1;

-- Consulta: todas las transacciones registradas
SELECT
    t.transaction_id,
    emisor.nombre AS emisor,
    receptor.nombre AS receptor,
    m.currency_name AS moneda,
    t.amount AS importe,
    t.transaction_date AS fecha
FROM transaccion AS t
INNER JOIN usuario AS emisor ON t.sender_user_id = emisor.user_id
INNER JOIN usuario AS receptor ON t.receiver_user_id = receptor.user_id
INNER JOIN moneda AS m ON t.currency_id = m.currency_id
ORDER BY t.transaction_date DESC;

-- Consulta: transacciones enviadas o recibidas por un usuario específico
SELECT
    t.transaction_id,
    emisor.nombre AS emisor,
    receptor.nombre AS receptor,
    m.currency_name AS moneda,
    t.amount AS importe,
    t.transaction_date AS fecha
FROM transaccion AS t
INNER JOIN usuario AS emisor ON t.sender_user_id = emisor.user_id
INNER JOIN usuario AS receptor ON t.receiver_user_id = receptor.user_id
INNER JOIN moneda AS m ON t.currency_id = m.currency_id
WHERE t.sender_user_id = 1 OR t.receiver_user_id = 1
ORDER BY t.transaction_date DESC;

-- DML: modificar correo electrónico de un usuario
UPDATE usuario
SET email = 'marcel.nuevo@example.com'
WHERE user_id = 1;

-- DML: eliminar una transacción completa
-- DELETE FROM transaccion
-- WHERE transaction_id = 3;

-- Ejemplo de transferencia atómica
START TRANSACTION;

UPDATE usuario
SET saldo = saldo - 10000.00
WHERE user_id = 1 AND saldo >= 10000.00;

UPDATE usuario
SET saldo = saldo + 10000.00
WHERE user_id = 2;

INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, amount)
VALUES (1, 2, 1, 10000.00);

COMMIT;

-- Ejemplo de reversión de cambios
START TRANSACTION;

UPDATE usuario
SET saldo = saldo - 5000.00
WHERE user_id = 1 AND saldo >= 5000.00;

UPDATE usuario
SET saldo = saldo + 5000.00
WHERE user_id = 2;

INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, amount)
VALUES (1, 2, 1, 5000.00);

ROLLBACK;
