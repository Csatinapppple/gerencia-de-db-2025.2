-- Criação do banco e tabelas principais

DROP DATABASE IF EXISTS lab_functions;

CREATE DATABASE lab_functions CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci; USE lab_functions;

CREATE TABLE categories (id INT PRIMARY KEY, name VARCHAR(100));
CREATE TABLE products (id INT PRIMARY KEY, name VARCHAR(150), category_id INT, price DECIMAL(10,2), created_at DATETIME);
CREATE TABLE customers (id INT PRIMARY KEY, name VARCHAR(150), email VARCHAR(150), city VARCHAR(100), state VARCHAR(50), created_at DATETIME);
CREATE TABLE orders (id INT PRIMARY KEY, customer_id INT, order_date DATETIME, status VARCHAR(30), shipped_date DATETIME, shipper VARCHAR(100), freight DECIMAL(10,2));
CREATE TABLE order_items (order_id INT, product_id INT, quantity INT, unit_price DECIMAL(10,2), discount DECIMAL(5,2), PRIMARY KEY(order_id, product_id));
CREATE TABLE departments (id INT PRIMARY KEY, name VARCHAR(100));
CREATE TABLE employees (id INT PRIMARY KEY, first_name VARCHAR(100), last_name VARCHAR(100), department_id INT, hire_date DATE, salary DECIMAL(10,2), manager_id INT);
CREATE TABLE attendance (id INT PRIMARY KEY, employee_id INT, day DATE, check_in TIME, check_out TIME);
CREATE TABLE payments (id INT PRIMARY KEY, customer_id INT, payment_date DATE, amount DECIMAL(10,2), method VARCHAR(50));
CREATE TABLE reviews (id INT PRIMARY KEY, product_id INT, customer_id INT, rating INT, comment VARCHAR(400), review_date DATE);
