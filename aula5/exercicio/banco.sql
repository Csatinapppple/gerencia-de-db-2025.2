

CREATE TABLE contas (
	id INTEGER PRIMARY KEY,
	nome TEXT NOT NULL,
	saldo REAL NOT NULL CHECK( saldo >= 0.0)
);


INSERT INTO contas 
(nome, saldo) VALUES
('Conta 1', 200),
('Conta 2', 100);

