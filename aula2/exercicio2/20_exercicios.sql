-- ESQUEMA DE TABELAS (DDL - sqlite3)

PRAGMA foreign_keys = ON;

CREATE TABLE clientes (
	id INTEGER PRIMARY KEY,
	nome TEXT NOT NULL,
	email TEXT UNIQUE,
	telefone TEXT,
	dt_nascimento TEXT,
	criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE veterinarios (
	id INTEGER PRIMARY KEY,
	nome TEXT NOT NULL,
	especialidade TEXT,
	registro_prof TEXT NOT NULL UNIQUE,
	email TEXT,
	telefone TEXT,
	ativo INTEGER NOT NULL DEFAULT 1 CHECK(ativo IN (0, 1) ) --boolean
);
CREATE TABLE animais (
	id INTEGER PRIMARY KEY ,
	nome TEXT NOT NULL,
	especie TEXT NOT NULL,
	raca TEXT,
	sexo TEXT CHECK(sexo IN ('M','F', NULL)),
	dt_nascimento TEXT,
	cliente_id INTEGER NOT NULL,
	CONSTRAINT fk_animal_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id)
		ON UPDATE CASCADE 
		ON DELETE RESTRICT
);
CREATE TABLE procedimentos (
	id INTEGER PRIMARY KEY ,
	nome TEXT NOT NULL,
	tipo TEXT NOT NULL CHECK(tipo IN ('consulta','vacina','exame','cirurgico','outro') ),
	valor_base REAL NOT NULL DEFAULT 0.00,
	ativo INTEGER NOT NULL DEFAULT 1 CHECK(ativo IN (0, 1)) --boolean
);
CREATE TABLE medicamentos (
	id INTEGER PRIMARY KEY ,
	nome TEXT NOT NULL,
	descricao TEXT ,
	concentracao TEXT ,
	unidade TEXT
);

CREATE TABLE consultas (
	id INTEGER PRIMARY KEY ,
	animal_id INTEGER NOT NULL,
	veterinario_id INTEGER NOT NULL,
	data_hora TEXT NOT NULL,
	status TEXT NOT NULL DEFAULT 'agendadas' CHECK(status IN ('agendada','realizada','cancelada','no-show') ),
	motivo_cancelamento TEXT NULL,
	observacoes TEXT,
	valor_total REAL NOT NULL DEFAULT 0.00,
	criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_consulta_animal FOREIGN KEY (animal_id) REFERENCES animais(id),
	CONSTRAINT fk_consulta_veterinario FOREIGN KEY (veterinario_id) REFERENCES veterinarios(id)
);

CREATE TABLE consulta_procedimentos (
	consulta_id INTEGER NOT NULL,
	procedimento_id INTEGER NOT NULL,
	quantidade INTEGER NOT NULL DEFAULT 1,
	valor_unit REAL NOT NULL,
	PRIMARY KEY (consulta_id, procedimento_id),
	CONSTRAINT fk_cp_consulta FOREIGN KEY (consulta_id) REFERENCES consultas(id)
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_cp_procedimento FOREIGN KEY (procedimento_id) REFERENCES procedimentos(id)
);

CREATE TABLE prescricoes (
	id INTEGER PRIMARY KEY ,
	consulta_id INTEGER NOT NULL,
	medicamento_id INTEGER NOT NULL,
	quantidade REAL NOT NULL DEFAULT 1,
	posologia TEXT,
	CONSTRAINT fk_presc_consulta FOREIGN KEY (consulta_id) REFERENCES consultas(id),
	CONSTRAINT fk_presc_medicamento FOREIGN KEY (medicamento_id) REFERENCES medicamentos(id)
);

CREATE TABLE pagamentos (
	id INTEGER PRIMARY KEY ,
	consulta_id INTEGER NOT NULL,
	data_pagto TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	valor REAL NOT NULL,
	metodo TEXT NOT NULL CHECK(metodo IN ('dinheiro','debito','credito','pix','boleto') ),
	status TEXT NOT NULL DEFAULT 'pago' CHECK (status IN ('pago','pendente','estornado') ),
	CONSTRAINT fk_pagto_consulta FOREIGN KEY (consulta_id) REFERENCES consultas(id)
);
