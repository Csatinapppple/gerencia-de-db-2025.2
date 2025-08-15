--3) Tornar `cidade` NOT NULL e definir default.
--ALTER TABLE clientes MODIFY cidade VARCHAR(80) NOT NULL DEFAULT 'Indefinida';

BEGIN TRANSACTION;

CREATE TABLE clientes_temp (
	id INTEGER PRIMARY KEY ,
	nome TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE,
	cidade TEXT NOT NULL DEFAULT 'Indefinida',
	estado TEXT CHECK(LENGTH(estado) = 2),
	criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clientes_temp 
(id, nome, email, cidade, estado, criado_em)
SELECT 
id, nome, email, coalesce(cidade, 'Indefinida') AS cidade, estado, criado_em 
from clientes;

PRAGMA foreign_keys = OFF;

DROP TABLE clientes;
ALTER TABLE clientes_temp RENAME TO clientes;

PRAGMA foreign_keys = ON;

COMMIT;