use banco;

-- crie os dados com o arquivo conta2.sql

-- 1) TRANSFERÊNCIA ATÔMICA COM COMMIT/ROLLBACK (MySQL/InnoDB)
-- Crie a tabela contas(id INT PK, saldo DECIMAL(10,2)) e insira duas linhas. Faça START TRANSACTION; 
-- UPDATE para debitar R$200 de A e creditar em B; verifique com SELECT dentro
-- e fora da transação (em outra sessão). Finalize com COMMIT e repita depois fazendo ROLLBACK.
-- Observe os saldos.

-- Sessão 1
START TRANSACTION;
UPDATE contas SET saldo = saldo - 200 WHERE id = 1;
UPDATE contas SET saldo = saldo + 200 WHERE id = 2;
-- Verifique os saldos dentro da transação
SELECT * FROM contas;

-- Volte para Sessão 1 e faça COMMIT
COMMIT;

-- Sessão 2

-- Agora em Sessão 2 os valores atualizados serão visíveis
SELECT * FROM contas;

-- Para testar ROLLBACK, repita mas faça ROLLBACK ao invés de COMMIT
START TRANSACTION;
UPDATE conta SET saldo = saldo - 200 WHERE id = 1;
UPDATE conta SET saldo = saldo + 200 WHERE id = 2;
SELECT * FROM contas; -- Mostra valores atualizados
ROLLBACK; -- Desfaz todas as alterações

-- Verifique que os valores voltaram ao original
SELECT * FROM contas;

/*
	Se fizer o select dentro da primeira sessão após os UPDATEs, sera visivel as mudanças feitas
	mas se voce fizer um SELECT em outra Sessão, uma conexao diferente vendo o banco, não
	haverá mudanças ate o COMMIT da primeira sessão ser feito.
 */

-- 2) DEADLOCK NA PRÁTICA COM FOR UPDATE
-- Sessão 1: START TRANSACTION; SELECT * FROM contas WHERE id=1 FOR UPDATE; 
-- Sessão 2: START TRANSACTION; SELECT * FROM contas WHERE id=2 FOR UPDATE; 
-- Sessão 1: SELECT * FROM contas WHERE id=2 FOR UPDATE; 
-- Sessão 2: SELECT * FROM contas WHERE id=1 FOR UPDATE;
-- Explique o deadlock detectado e o rollback automático de uma das sessões.
COMMIT;
-- Sessão 1:
START TRANSACTION;-- 1
SELECT * FROM contas WHERE id=1 FOR UPDATE; -- 1
SELECT * FROM contas WHERE id=2 FOR UPDATE; -- 3
-- Sessão 2:
START TRANSACTION; -- 2
SELECT * FROM contas WHERE id=2 FOR UPDATE; -- 2
SELECT * FROM contas WHERE id=1 FOR UPDATE; -- 4

/*
	Na parte da Sessão 1 em que se tenta ler o ID 2 que está sendo preso pela Sessão 2
	se tem um timeout de tanto esperar pelo lock que a sessão 2 possui e se tera esse
	log como saida.
	SQL Error [1205] [40001]: Lock wait timeout exceeded; try restarting transaction
	A Sessão 2 precisa dar COMMIT para liberar o lock para a Sessão 1,
	Mas se a Sessão 2 rodar o comando -- 4 dentro desse timeout, vai se ter um erro de DEADLOCK
	pois as 2 sessões estão se trancando.
	SQL Error [1213] [40001]: Deadlock found when trying to get lock; try restarting transaction
***/


-- 3) ISOLATION LEVEL – NON-REPEATABLE READ (READ COMMITTED)
-- Sessão 1: SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 
-- START TRANSACTION; SELECT saldo FROM contas WHERE id=1; 
-- Sessão 2: UPDATE contas SET saldo = saldo + 10 WHERE id=1; COMMIT; 
-- Sessão 1: SELECT saldo FROM contas WHERE id=1;
-- Mostre que o valor mudou dentro da mesma transação (não repetível).

-- Sessão 1:
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT saldo FROM contas WHERE id=1;

-- Sessão 2:
UPDATE contas SET saldo = saldo + 10 WHERE id=1;
COMMIT;

/*
 	O Saldo da conta com ID 1 foi aumentado na Sessão 2 e mesmo assim é visivel da Sessão 1
 	pois o status de isolamento da TRANSACTION da Sessão 1 so deixa ler mudancas de outras transações
 	somente depois de elas serem commitadas.
 */

-- 4) PHANTOM READ COM READ COMMITTED
-- Crie tabela pedidos(id INT PK, valor DECIMAL(10,2), status ENUM('P','F')). 
-- Sessão 1: SET TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION;
-- SELECT COUNT(*) FROM pedidos WHERE status='P'; 
-- Sessão 2: INSERT INTO pedidos VALUES(...,'P'); COMMIT; 
-- Sessão 1: repita o COUNT; explique o 'fantasma'.

-- Sessão 1:
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT COUNT(*) FROM pedidos WHERE status='P';

-- Sessão 2:
INSERT INTO pedidos (valor, status) VALUES (626.00, 'P');
COMMIT;

/*
	O phantom read ocorre apos o commit da sessão 2, ja que o resultado antigo da sessão 1
	era n ocorrencias de status = P no banco mas após o commit da Sessão 2 na mesma transação
	da Sessão 1 se teve N + 1 ocorrencias no banco, sendo um resultado fantasma.
**/



-- 5) SAVEPOINT E ROLLBACK PARCIAL
-- START TRANSACTION; UPDATE contas SET saldo=saldo-50 WHERE id=1; SAVEPOINT s1;
-- UPDATE contas SET saldo=saldo-100 WHERE id=1; ROLLBACK TO s1; Verifique que apenas o
-- primeiro UPDATE permaneceu. COMMIT.

START TRANSACTION;
UPDATE contas SET saldo = saldo - 50 WHERE id = 1;
SAVEPOINT s1;
UPDATE contas SET saldo = saldo - 100 WHERE id = 1;
ROLLBACK TO s1;
COMMIT;

-- SIM somente o primeiro update permaneceu.

-- 6) FOR UPDATE vs FOR SHARE
-- Mostre, em duas sessões, a diferença entre SELECT ... FOR UPDATE (bloqueio exclusivo) e
-- SELECT ... FOR SHARE (bloqueio compartilhado). Demonstre que FOR SHARE permite múltiplas
-- leituras concorrentes, mas impede updates.

-- Sessão 1 e 2:

SELECT * FROM contas WHERE id = 1; -- 1

-- Sessão 1
START TRANSACTION;
SELECT * FROM contas WHERE id = 1 FOR UPDATE; -- 2
COMMIT; -- 4 Libera o lock

START TRANSACTION;
SELECT * FROM contas WHERE id = 1 FOR SHARE; -- 5 pega o lock compartilhado
COMMIT; -- 8 Libera o lock compartilhado
-- Sessão 2
START TRANSACTION;
SELECT * FROM contas WHERE id = 1 FOR UPDATE; -- 3 Vai ser bloqueado pela Sessão 1, 6 vai ser permitido pela Sessão 1
UPDATE contas SET valor = valor - 10 WHERE id = 1; -- 7 Vai ser Bloqueado pela Sessão 1 pois o SHARED LOCK nao deixa alterações
ROLLBACK;
 

-- 7) FILA COM SKIP LOCKED / NOWAIT (MySQL 8)
-- Crie tabela fila(id INT PK, status ENUM('N','P','C'), payload JSON). 
-- Sessão 1: START TRANSACTION; SELECT id FROM fila WHERE status='N' ORDER BY id LIMIT 1 FOR UPDATE SKIP LOCKED;
-- Atualize para status='P'; 
-- Sessão 2: tente pegar o próximo item com SKIP LOCKED
-- (não bloqueia). Repita com NOWAIT e explique o erro imediato de lock.

-- Sessão 1
START TRANSACTION;						--	|
SELECT id FROM fila 					--	|
WHERE status='N' 						--	|
ORDER BY id 							--	|  1
LIMIT 1 								--	|
FOR UPDATE SKIP LOCKED;					--	|
UPDATE fila SET status = 'P' WHERE id = 1;-- |

ROLLBACK; -- | 4
-- Sessao 2
START TRANSACTION;

SELECT id FROM fila 						-- |
WHERE status='N' 							-- |
ORDER BY id 								-- |
LIMIT 1 									-- | 2
FOR UPDATE SKIP LOCKED;						-- | 

UPDATE fila SET status = 'P' WHERE id = 2;	-- |

ROLLBACK; -- | 3

/*
	Quando se tem a especificacao SKIP LOCKED, se alguma linha for
	travada por alguma outra sessão então a sessão atual vai procurar
	a proxima instancia que se encaixa na procura que não possui uma trava
	garantindo assim a concurrencia.
**/

-- NOWAIT:
-- Sessão 1
START TRANSACTION;						--	|
SELECT id FROM fila 					--	|
WHERE status='N' 						--	|
ORDER BY id 							--	|  1
LIMIT 1 								--	|
FOR UPDATE NOWAIT;					--	|
UPDATE fila SET status = 'P' WHERE id = 1;-- |

COMMIT; -- | 4

-- Sessão 2:
START TRANSACTION;						--	|
SELECT id FROM fila 					--	|
WHERE status='N' 						--	|
ORDER BY id 							--	|  3 Vai falhar com o erro 3572
LIMIT 1 								--	|
FOR UPDATE NOWAIT;					--	|
UPDATE fila SET status = 'P' WHERE id = 1;-- |

ROLLBACK; -- | 4

/*

Se tem o seguinte Erro ao usar o NOWAIT
ERROR 3572 (HY000): Statement aborted because lock(s) could not be acquired immediately and NOWAIT is set. 
Então em vez de ter a trava e falhar por timeout quando se especifica o NOWAIT a falha ocorre imediatamente 
*/

-- 8) DIAGNÓSTICO DE DEADLOCK (SHOW ENGINE INNODB STATUS)
-- Provoque um deadlock (exercício 2) e, em seguida, execute: SHOW ENGINE INNODB STATUS\G
-- Copie o trecho 'LATEST DETECTED DEADLOCK' e identifique as transações e locks.


SHOW ENGINE INNODB STATUS;
/*
 ------------------------
LATEST DETECTED DEADLOCK
------------------------
2025-09-02 23:17:51 140622790907456
*** (1) TRANSACTION:
TRANSACTION 2676, ACTIVE 59 sec starting index read
mysql tables in use 1, locked 1
LOCK WAIT 3 lock struct(s), heap size 1128, 2 row lock(s)
MySQL thread id 41, OS thread handle 140623343478336, query id 583 localhost 127.0.0.1 root statistics
* ApplicationName=DBeaver 25.2.0 - SQLEditor <transacoes_pt2.sql> * -- 1
SELECT * FROM contas WHERE id=2 FOR UPDATE  Talvez seja o terceiro comando na Sessão 1

*** (1) HOLDS THE LOCK(S): a Sessão 1 esta com o lock da linha com ID = 1
RECORD LOCKS space id 4 page no 4 n bits 72 index PRIMARY of table `banco`.`contas` trx id 2676 lock_mode X locks rec but not gap
Record lock, heap no 2 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 80000001; asc     ;;
 1: len 6; hex 000000000a58; asc      X;;
 2: len 7; hex 01000001290151; asc     ) Q;;
 3: len 5; hex 800000a000; asc      ;;


*** (1) WAITING FOR THIS LOCK TO BE GRANTED: a Sessão 1 esta esperando para o lock da linha com ID = 2 ser liberada;
RECORD LOCKS space id 4 page no 4 n bits 72 index PRIMARY of table `banco`.`contas` trx id 2676 lock_mode X locks rec but not gap waiting
Record lock, heap no 3 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 80000002; asc     ;;
 1: len 6; hex 000000000a41; asc      A;;
 2: len 7; hex 02000001230174; asc     # t;;
 3: len 5; hex 8000012c00; asc    , ;;

Pode se deduzir então que a Sessão 2 (que iniciou o deadlock) foi derrubada a favor da Sessão 1

 */

SHOW PROCESSLIST; -- mostra os processos

-- dados do processo com ID 41
/*
"Id","User","Host","db","Command","Time","State","Info"
41,root,localhost:52294,banco,Query,0,init,/ ApplicationName=DBeaver 25.2.0 - SQLEditor <transacoes_pt2.sql> / SHOW PROCESSLIST
*/

-- 9) AUTOCOMMIT, TRANSAÇÕES IMPLÍCITAS E DURABILIDADE
-- SET autocommit=0; START TRANSACTION; UPDATE contas SET saldo=saldo+1 WHERE id=2;
-- Em outra sessão leia o saldo (não deve ver a mudança). Faça COMMIT e confirme a visibilidade.
-- Explique o comportamento se ocorrer ROLLBACK em vez de COMMIT.

-- Sessão 1:
SET autocommit=0;
START TRANSACTION;
UPDATE contas SET saldo = saldo+1 WHERE id=2; 
COMMIT;
ROLLBACK;
-- Sessão 2:
SELECT * FROM contas WHERE id = 2;

-- Se ocorrer ROLLBACK em vez de COMMIT o valor final vai ser N em vez de N + 1 e vai ser visivel na Sessão 2

/*
10) CONSISTENT SNAPSHOT (MVCC) E GAP LOCKS
Crie tabela produtos(id INT PK, preco DECIMAL(10,2)); insira várias linhas. 
Sessão 1: START TRANSACTION WITH CONSISTENT SNAPSHOT; 
SELECT AVG(preco) FROM produtos WHERE id BETWEEN 10 AND 100; 
Sessão 2: insira/atualize linhas nesse intervalo e faça COMMIT.
Sessão 1: repita a mesma SELECT (sem locking read) e comente a leitura consistente. Depois
repita usando SELECT ... FOR UPDATE para observar locks (next-key/gap).
*/

-- Sessão 1:
START TRANSACTION WITH CONSISTENT SNAPSHOT;
SELECT AVG(preco) FROM produtos WHERE id BETWEEN 10 and 100; -- resultado deu 450 com as linhas ja preparadas antes da Sessão 2 alterar.
-- ainda leu 450 depois da sessão 2 alterar
SELECT * FROM produtos WHERE id BETWEEN 10 AND 100 FOR UPDATE;

SELECT * FROM performance_schema.data_locks 
WHERE OBJECT_NAME = 'produtos';

-- Sessão 2:
START TRANSACTION
UPDATE produtos SET preco = preco + 50 WHERE id = 10;
SELECT * from produtos where id = 10;
COMMIT;

-- Tera um timeout ao tentar acessar com update as linhas que estão trancadas.
