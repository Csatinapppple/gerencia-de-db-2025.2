-- usar com a parte 2 do exercicio de transacoes

CREATE DATABASE IF NOT EXISTS banco CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE banco;

CREATE TABLE IF NOT EXISTS contas (
	id INT PRIMARY KEY AUTO_INCREMENT,
	saldo DECIMAL(10,2) NOT NULL check( saldo >= 0.00)
);


INSERT INTO contas (saldo) VALUES
(200.0),
(300.0);

CREATE TABLE IF NOT EXISTS pedidos(
	id INT PRIMARY KEY AUTO_INCREMENT,
	valor DECIMAL(10, 2) NOT NULL CHECK( valor >= 0.00),
	status ENUM('P','F') NOT NULL DEFAULT 'P'
);

-- Inserting sample data into the pedidos table
INSERT INTO pedidos (valor, status) VALUES
-- Pedidos Pendentes (status 'P')
( 49.99, 'P'),
( 125.50, 'P'),
( 299.00, 'P'),
( 15.75, 'P'),
-- Pedidos Finalizados (status 'F')
( 88.40, 'F'),
( 550.00, 'F'),
( 12.99, 'F'),
( 999.99, 'F'),
-- A pedido with a high value, still pending
( 2500.00, 'P'),
-- A pedido with a very small value, finalized
( 5.25, 'F');

CREATE TABLE IF NOT EXISTS fila(
	id INT PRIMARY KEY AUTO_INCREMENT,
	status ENUM('N','P','C') NOT NULL,
	payload JSON
);

INSERT INTO fila (status) VALUES
('N'), -- New task 1
('N'), -- New task 2
('P'), -- Processing task 3
('N'), -- New task 4
('C'), -- Completed task 5
('P'), -- Processing task 6
('N'), -- New task 7
('C'), -- Completed task 8
('N'), -- New task 9
('C'); -- Completed task 10

CREATE TABLE IF NOT EXISTS produtos(
	id INT PRIMARY KEY AUTO_INCREMENT,
	preco DECIMAL(10, 2)
);


INSERT INTO produtos (id, preco) VALUES
(1, 10.50), (5, 25.00), (10, 100.00), (15, 150.00), 
(20, 200.00), (50, 500.00), (75, 750.00), (100, 1000.00),
(105, 150.00), (110, 200.00);
