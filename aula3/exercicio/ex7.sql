--7) Adicionar constraint CHECK para e-mail.

BEGIN TRANSACTION;

CREATE TABLE clientes_new (
	id INTEGER PRIMARY KEY ,
	nome TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE,
	cidade TEXT,
	estado TEXT CHECK(LENGTH(estado) = 2),
	criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT chk_email_formato CHECK(email LIKE '%@%.__%' )
);


INSERT INTO clientes_new SELECT * FROM clientes WHERE email LIKE '%@%.__%';

PRAGMA foreign_keys = OFF;

DROP TABLE clientes;
ALTER TABLE clientes_new RENAME TO clientes;

PRAGMA foreign_keys = ON;


COMMIT;
