 USE banco;
-- 1. Escreva um exemplo SQL de transação que transfira R$ 200 da conta A para a conta B. Mostre como ficariam os comandos BEGIN, COMMIT e ROLLBACK.

DELIMITER //
CREATE PROCEDURE  transfere(IN p_from INT, IN p_to INT, IN p_valor DECIMAL(10,2))
BEGIN
START TRANSACTION; 

IF @debito_ok < 0.00 THEN
	ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
END IF;

Update conta set valor  = valor + 200 WHERE id = 1;
Update conta set valor  = valor - 200 WHERE id = 2;

Select valor INTO @debito_ok from conta WHERE id = 2;

COMMIT;
END//

DELIMITER ;

CALL transfere(2, 1, 200.00);


-- 2. Dado o cenário de transferência entre contas, explique o que aconteceria se a transação falhar após o UPDATE da conta A, mas antes do UPDATE da conta B.

/* 
Se o Valor de uma conta for atualziado com Sucesso mas o valor da segunda não for atualizado com sucesso
a primeira conta sera atualizada enquanto um roolback ira ocorrer no valor da segunda conta gerando uma inconsistencia

*/

-- 3. Simule em SQL duas transações concorrentes que tentam atualizar o estoque de um mesmo produto. Mostre por que o requisito de isolamento é importante.


START TRANSACTION;
Update Item Set estoque = estoque - 750 WHERE id = 'T000154'
Commit;

START TRANSACTION;
Update Item Set estoque = estoque + 500 WHERE id = 'T000154'
Commit;
-- Caso as duas transações occorressem ao mesmo tempo há a possibilidade do estoque ter o incremento de 500 utilizando o valor antes da subtração de 750 e ter um valor errado final

-- 4. Explique como garantir a atomicidade no caso de falha de energia durante uma transação.

/*
Utilizando Logs que contem as modificações executadas nos bancos de dados e refazendo as operações dos logs
usando shadow tables que guardam a informação por um curto periodo de tempo antes de mudar
sistema de backup remoto, salvar os dados em dois locais
*/

-- 5. Classifique a seguinte situação: 'Um valor é debitado de uma conta, mas o crédito correspondente não acontece'. Isso é falha de atomicidade ou consistência?

/*
 é uma falha de Atomicidade
*/


-- 6. Monte um schedule serial e um schedule concorrente equivalente para duas transações: T1: sacar R$ 100 da conta A. T2: depositar R$ 50 na conta B.

/*
				SERIAL
		T1				T2
		r1(A)			
        A:= A - 100;
		w1(A)			
						r2(B)		
                        B:= B + 50;
						w2(B)
                        
				CONCORRENTE
		T1				T2
		r1(A)			r2(B)
        A:= A - 100;
		w1(A)					
                        B:= B + 50;
						w2(B)
                        r1(A)
                        A:= A - 100;
						w1(A)
		r2(B)
        B:= B + 50;
		w2(B)
*/


-- 7. Dado o seguinte schedule, determine se é serializável por conflito: T1: read(A), write(A) | T2: read(A), write(A).
		
/*
        T1				T2
        read(A)
        write(A)
						read(A)
                        write(A)
                        
	é serializável por conflito
*/             
         
-- 8. Explique por que o problema da leitura suja (dirty read) pode gerar inconsistências. Dê um exemplo SQL.

/*
	Leituras sujas acontem quando lemos um valor que esta sendo alterado em uma transaction antes dele ser comitado
    Como no exemplo abaixo se a transaction estiver executando ao mesmo tempo do select, ele pode retornar um valor inconsistênte
*/


START TRANSACTION;
Update Item Set estoque = estoque - 750 WHERE id = 'T000154'
Commit;

SELECT estoque FROM Item WHERE id = 'T000154'


-- 9. Simule em SQL uma situação de leitura não-repetível, usando duas transações.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT valor FROM conta WHERE id = 1;


SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

-- altera o valor e confirma
UPDATE conta SET valor = 150 WHERE id = 1;
COMMIT;

SELECT valor FROM conta WHERE id = 1;

COMMIT;

-- 10. Explique como ocorre o fenômeno phantom (tupla fantasma) e construa um exemplo usando INSERT em uma tabela de funcionários.

/*
	o fenômeno phantom ocorre quando uma query esta lendo linhas em loop mas durante uma leitura subsequente novas linhas são inseridas que não existiam anteriormente
*/
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

-- Primeira leitura
SELECT * FROM conta WHERE valor > 1000;

START TRANSACTION;
 INSERT INTO conta (numero, valor) VALUES (784454987, 125885.05);
COMMIT;

SELECT * FROM conta WHERE valor > 1000;
COMMIT;

-- 11. Crie um exemplo em SQL que mostre a necessidade de usar um bloqueio compartilhado (S) e um bloqueio exclusivo (X).

START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR SHARE;
 
-- faz algo com o valor
 
START TRANSACTION;
UPDATE conta SET valor = valor - 50 WHERE id = 1;
-- t2 fica bloqueada até t1 terminar
COMMIT;
COMMIT;


START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR UPDATE;
 
-- faz algo com o valor
 
START TRANSACTION;
UPDATE conta SET valor = valor - 50 WHERE id = 1;
-- t2 fica bloqueada até t1 terminar
COMMIT;
COMMIT;


-- 12. Explique como o protocolo 2PL (Two-Phase Locking) funciona e simule uma execução curta com duas transações que usam locks.

START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR SHARE;
-- faz algo com o valor
START TRANSACTION;
SELECT valor FROM conta WHERE id = 1 FOR UPDATE;
UPDATE conta SET valor = valor - 50 WHERE id = 1;
-- t2 fica bloqueada até t1 terminar
COMMIT;
SELECT valor FROM conta WHERE id = 1 FOR SHARE;
COMMIT;


-- 13.Mostre uma situação em que ocorre deadlock entre duas transações e como o SGBD poderia resolver com rollback.

START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR UPDATE;
SELECT valor FROM conta WHERE id = 2 FOR UPDATE;
-- faz algo com o valor
START TRANSACTION;
SELECT valor FROM conta WHERE id = 2 FOR UPDATE;
SELECT valor FROM conta WHERE id = 1 FOR UPDATE;
-- t2 fica bloqueada até t1 terminar

-- 14. Crie um exemplo que ilustre o problema da inanição (starvation) em bloqueios.
START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR SHARE;
-- faz algo com o valor
START TRANSACTION;
SELECT valor FROM conta WHERE id = 1 FOR UPDATE;

START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR SHARE;

START TRANSACTION;
-- t1 aplica o bloqueio compatilhado
SELECT valor FROM conta WHERE id = 1 FOR SHARE;


-- 15. Mostre como aplicar a cláusula SQL SET TRANSACTION ISOLATION LEVEL SERIALIZABLE em um exemplo de atualização de dados.

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

UPDATE conta SET valor = 380.00 WHERE id =1;

COMMIT;

-- 16. Explique como os registros de log UNDO e REDO ajudam a restaurar o banco de dados após uma falha.

/*
	logs UNDO mantém apenas o valor antigo do dado antes da alteração
    enquanto REDO mantém apenas o valor dos dados depois da alteração
    
    estes registros mantém um histórico de modificações do banco de dados, e em caso de perda de dados ou de alteração errada
    podemos utilizar estes logs para retornar o banco para um estado antes de alterações.
*/

-- 17. Simule em SQL uma transação com UPDATE e COMMIT, e mostre o que o sistema deveria fazer se houver queda logo após o UPDATE mas antes do COMMIT.

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

UPDATE conta SET valor = 380.00 WHERE id =1;

-- SISTEMA MORRE, não da o Commit
-- o banco usa o UNDO LOG para reverter qualquer transação não confirmado

COMMIT;

-- 18. Explique a diferença prática entre os esquemas de modificação adiada e modificação imediata em logs de recuperação.

/*
	A Imediata ocorre logo após a modificação salvando no log imediatamente
    A adiada ocorre somente após a confirmação ocorrer de fato no banco de dados
*/

-- 19. Mostre como funcionaria a recuperação via shadow page em um exemplo de inserção de registro.

/*

	Quando fazemos um Insert como INSERT INTO Clientes(id=42, nome='Ana')
    salvamos os dados em ambas as tabelas, a shadow table é mantidade em memória não volátil para recuperação
    caso um problema ocorra durante uma serie de operações e o banco caia, os dados estaram salvos na tabela sombra.
    Ao reiniciar o banco o SGBD vai verificar se a tabela sombra esta igual a tabela normal, se estiver diferente sabesse que dados não foram comitados para a tabela de uso

*/

-- 20. Explique como o algoritmo ARIES melhora o tempo de recuperação em comparação a métodos mais antigos

/*
	O logs utiliza de vários mecanismos para atingir o objetivo de atingir atomicidade no sistema e baixo custo de subida.
    1 - WAL(Write-ahead logging) Qualquer mudança em uma tabela é primeiro salva em log e depois escrita em uma tabela em disco
    2 - Os logs não armazenam a página inteira mas somente a mudança para os updates necessários no disco
    3 - Ao reiniciar o banco o ARIES faz uma analize de transações que estavam ativas e quais páginas podem estar sujas,
    reaplica as mudanças desde o último checkpoint e desfaz as transações inacabadas
	4 - Ao fazer o checkpoint do banco de dados o sistema mantém uma lista de tabelas sujas, ou seja que foram modificas e ainda não foram salvas em disco,
    e faz um checkpoint incremental somente com esta lista de tabela.
*/