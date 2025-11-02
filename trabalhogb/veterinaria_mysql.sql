-- ESQUEMA DE TABELAS (DDL - MySQL 8+)
DROP DATABASE IF EXISTS clinica_vet;

CREATE DATABASE clinica_vet;

USE clinica_vet;

CREATE TABLE
	clientes (
		id INT PRIMARY KEY AUTO_INCREMENT,
		nome VARCHAR(120) NOT NULL,
		email VARCHAR(120) UNIQUE,
		telefone VARCHAR(30),
		dt_nascimento DATE,
		criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
	);

CREATE TABLE
	veterinarios (
		id INT PRIMARY KEY AUTO_INCREMENT,
		nome VARCHAR(120) NOT NULL,
		especialidade VARCHAR(80),
		registro_prof VARCHAR(40) NOT NULL UNIQUE,
		email VARCHAR(120),
		telefone VARCHAR(30),
		ativo TINYINT(1) NOT NULL DEFAULT 1
	);

CREATE TABLE
	animais (
		id INT PRIMARY KEY AUTO_INCREMENT,
		nome VARCHAR(80) NOT NULL,
		especie VARCHAR(40) NOT NULL,
		raca VARCHAR(60),
		sexo ENUM('M', 'F') NULL,
		dt_nascimento DATE,
		cliente_id INT NOT NULL,
		CONSTRAINT fk_animal_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT
	);

CREATE TABLE
	procedimentos (
		id INT PRIMARY KEY AUTO_INCREMENT,
		nome VARCHAR(120) NOT NULL,
		tipo ENUM('consulta', 'vacina', 'exame', 'cirurgico', 'outro') NOT NULL,
		valor_base DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
		ativo TINYINT(1) NOT NULL DEFAULT 1
	);

CREATE TABLE
	medicamentos (
		id INT PRIMARY KEY AUTO_INCREMENT,
		nome VARCHAR(120) NOT NULL,
		descricao VARCHAR(255),
		concentracao VARCHAR(60),
		unidade VARCHAR(20)
	);

CREATE TABLE
	consultas (
		id INT PRIMARY KEY AUTO_INCREMENT,
		animal_id INT NOT NULL,
		veterinario_id INT NOT NULL,
		data_hora DATETIME NOT NULL,
		status ENUM('agendada', 'realizada', 'cancelada', 'no-show') NOT NULL DEFAULT 'agendada',
		motivo_cancelamento VARCHAR(200) NULL,
		observacoes TEXT,
		valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
		criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		CONSTRAINT fk_consulta_animal FOREIGN KEY (animal_id) REFERENCES animais (id),
		CONSTRAINT fk_consulta_veterinario FOREIGN KEY (veterinario_id) REFERENCES veterinarios (id)
	);

CREATE TABLE
	consulta_procedimentos (
		consulta_id INT NOT NULL,
		procedimento_id INT NOT NULL,
		quantidade INT NOT NULL DEFAULT 1,
		valor_unit DECIMAL(10, 2) NOT NULL,
		PRIMARY KEY (consulta_id, procedimento_id),
		CONSTRAINT fk_cp_consulta FOREIGN KEY (consulta_id) REFERENCES consultas (id) ON UPDATE CASCADE ON DELETE CASCADE,
		CONSTRAINT fk_cp_procedimento FOREIGN KEY (procedimento_id) REFERENCES procedimentos (id)
	);

CREATE TABLE
	prescricoes (
		id INT PRIMARY KEY AUTO_INCREMENT,
		consulta_id INT NOT NULL,
		medicamento_id INT NOT NULL,
		quantidade DECIMAL(10, 2) NOT NULL DEFAULT 1,
		posologia VARCHAR(255),
		CONSTRAINT fk_presc_consulta FOREIGN KEY (consulta_id) REFERENCES consultas (id),
		CONSTRAINT fk_presc_medicamento FOREIGN KEY (medicamento_id) REFERENCES medicamentos (id)
	);

CREATE TABLE
	pagamentos (
		id INT PRIMARY KEY AUTO_INCREMENT,
		consulta_id INT NOT NULL,
		data_pagto DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		valor DECIMAL(10, 2) NOT NULL,
		metodo ENUM('dinheiro', 'debito', 'credito', 'pix', 'boleto') NOT NULL,
		status ENUM('pago', 'pendente', 'estornado') NOT NULL DEFAULT 'pago',
		CONSTRAINT fk_pagto_consulta FOREIGN KEY (consulta_id) REFERENCES consultas (id)
	);