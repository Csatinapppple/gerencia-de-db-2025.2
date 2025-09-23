-- 1. Crie um índice para acelerar buscas por clientes.documento.
-- o Objetivo: usar EXPLAIN para confirmar uso do índice em 
-- SELECT * FROM clientes WHERE documento = '...'.
CREATE INDEX idx_clientes_documento ON clientes(documento);

-- Verifique com EXPLAIN
EXPLAIN SELECT * FROM clientes WHERE documento = '12345678901';

-- 2. Avalie a necessidade de índice em clientes.cidade.
-- o Tarefa: rode SELECT ... WHERE cidade = 'Porto Alegre' antes/depois de criar INDEX idx_cidade (cidade) e compare rows no EXPLAIN.

-- Primeiro, verifique sem índice
EXPLAIN SELECT * FROM clientes WHERE cidade = 'Porto Alegre';

-- Crie o índice
CREATE INDEX idx_clientes_cidade ON clientes(cidade);

-- Verifique novamente
EXPLAIN SELECT * FROM clientes WHERE cidade = 'Porto Alegre';

-- 3. Índice composto para range + igualdade.
-- o Crie INDEX idx_pedidos_cliente_criado (cliente_id, criado_em) e otimize consultas:
-- SELECT * FROM pedidos WHERE cliente_id = ? AND criado_em BETWEEN ? AND ?;

CREATE INDEX idx_pedidos_cliente_criado ON pedidos(cliente_id, criado_em);

-- Teste a consulta
EXPLAIN SELECT * FROM pedidos 
WHERE cliente_id = 1 
AND criado_em BETWEEN '2024-01-01' AND '2024-12-31';

-- 4. Cobertura de consulta (covering index).
-- o Crie INDEX idx_produtos_categoria_preco_nome (categoria, preco, nome) e execute:
-- SELECT categoria, preco, nome FROM produtos WHERE categoria = 'Notebook' AND preco < 5000;
-- o Objetivo: verificar Using index no EXPLAIN.

CREATE INDEX idx_produtos_categoria_preco_nome ON produtos(categoria, preco, nome);

-- Teste a consulta
EXPLAIN SELECT categoria, preco, nome FROM produtos 
WHERE categoria = 'Notebook' AND preco < 5000;

-- 5. Unique vs. não-unique.
-- o Compare UNIQUE(email) (já existe) com um índice normal em nome.
-- o Explique impacto de unicidade em escrita/leitura.

-- Já existe UNIQUE(email), vamos criar índice normal em nome
CREATE INDEX idx_clientes_nome ON clientes(nome);

-- Impacto: 
-- UNIQUE garante integridade mas tem custo adicional em INSERT/UPDATE
-- Índice normal é mais rápido para escrita mas permite duplicatas

-- 6. Quando NÃO criar índice.
-- o Teste SELECT ... WHERE ativo = 1 em produtos.
-- o Crie INDEX idx_produtos_ativo (ativo), compare EXPLAIN. Discuta baixa seletividade.

-- Teste sem índice
EXPLAIN SELECT * FROM produtos WHERE ativo = 1;

-- Crie o índice (não recomendado para baixa seletividade)
CREATE INDEX idx_produtos_ativo ON produtos(ativo);

-- Teste novamente
EXPLAIN SELECT * FROM produtos WHERE ativo = 1;
-- Discuta: se 99% dos produtos estão ativos, o índice não ajuda

-- 7. Prefix index em colunas grandes.
-- o Crie INDEX idx_clientes_nome_prefix (nome(20)) e compare com índice completo em nome para consulta LIKE 'Mar%'.

CREATE INDEX idx_clientes_nome_prefix ON clientes(nome(20));

-- Compare com:
EXPLAIN SELECT * FROM clientes WHERE nome LIKE 'Mar%';

-- 8. Otimizar LIKE com coringas.
-- o Compare WHERE nome LIKE 'note%' (usa índice) vs. LIKE '%book' (não usa).
-- o Proponha alternativa com coluna gerada reversa para sufixo (ou FULLTEXT
-- para buscas mais flexíveis).

-- Com índice (usa índice)
EXPLAIN SELECT * FROM produtos WHERE nome LIKE 'note%';

-- Sem índice (não usa índice)
EXPLAIN SELECT * FROM produtos WHERE nome LIKE '%book';

-- Alternativa: coluna gerada reversa
ALTER TABLE produtos ADD COLUMN nome_reverso VARCHAR(160) GENERATED ALWAYS AS (REVERSE(nome)) STORED;
CREATE INDEX idx_produtos_nome_reverso ON produtos(nome_reverso(20));

-- Consulta otimizada para sufixo:
SELECT * FROM produtos WHERE REVERSE(nome) LIKE REVERSE('%book');

-- 9. FULLTEXT em produtos.nome.
-- o Use MATCH(nome) AGAINST ('+gaming -used' IN BOOLEAN MODE) e compare com LIKE '%gaming%'.
-- o Medir relevância e desempenho.

-- Já existe FULLTEXT INDEX ftx_produtos_nome (nome)

-- Compare:
EXPLAIN SELECT * FROM produtos WHERE nome LIKE '%gaming%';
EXPLAIN SELECT * FROM produtos WHERE MATCH(nome) AGAINST('+gaming -used' IN BOOLEAN MODE);

-- 10. Índice para ORDER BY.
-- o Crie INDEX idx_pedidos_criado_total (criado_em, total) e otimize SELECT id, criado_em, total FROM pedidos WHERE criado_em >=
-- CURDATE() - INTERVAL 30 DAY ORDER BY criado_em, total; o Objetivo: evitar filesort.

CREATE INDEX idx_pedidos_criado_total ON pedidos(criado_em, total);

EXPLAIN SELECT id, criado_em, total FROM pedidos 
WHERE criado_em >= CURDATE() - INTERVAL 30 DAY 
ORDER BY criado_em, total;

-- 11. Índice para GROUP BY.
-- o Crie INDEX idx_pedidos_status (status) e avalie SELECT status, COUNT(*) FROM pedidos GROUP BY status; o Veja se o otimizador usa índice para agrupamento.

-- Já existe INDEX idx_pedidos_status (status)

EXPLAIN SELECT status, COUNT(*) FROM pedidos GROUP BY status;

-- 12. Escolha da ordem em índice composto.
-- o Compare (status, criado_em) vs (criado_em, status) para filtros comuns: a) WHERE status='PAGO' AND criado_em BETWEEN ...
-- b) WHERE criado_em BETWEEN ... apenas.
-- o Documente qual ordem atende melhor seu padrão.

-- Teste diferentes ordens:
CREATE INDEX idx_pedidos_status_criado ON pedidos(status, criado_em);
CREATE INDEX idx_pedidos_criado_status ON pedidos(criado_em, status);

-- Teste consultas:
EXPLAIN SELECT * FROM pedidos WHERE status='PAGO' AND criado_em BETWEEN '2024-01-01' AND '2024-12-31';
EXPLAIN SELECT * FROM pedidos WHERE criado_em BETWEEN '2024-01-01' AND '2024-12-31';

-- 13. Chave primária e clustered index do InnoDB.
-- o Explique por que PRIMARY KEY em InnoDB é o índice clustered e como isso impacta índices secundários (que carregam a PK como ponteiro).

-- InnoDB usa PK como índice clustered
-- Índices secundários referenciam a PK
SHOW INDEX FROM pedidos;

-- 14. Índice em FK.
-- o Verifique se pedidos(cliente_id) e itens_pedido(pedido_id, produto_id) têm índices adequados.
-- o Mostre impactos em JOIN e DELETE/UPDATE com cascata.

-- Verifique índices existentes:
SHOW INDEX FROM pedidos;
SHOW INDEX FROM itens_pedido;

-- Impacto: JOINs são mais rápidos com índices em FKs

-- 15. Índices “invisíveis” (MySQL 8.0+).
-- o Torne idx_pedidos_status_criado invisível e compare planos de execução antes/depois sem dropar o índice.
-- o Objetivo: testar impacto sem afetar DDL.

-- Torne índice invisível
ALTER TABLE pedidos ALTER INDEX idx_pedidos_status_criado INVISIBLE;

-- Teste consulta
EXPLAIN SELECT * FROM pedidos WHERE status = 'PAGO' ORDER BY criado_em;

-- Torne visível novamente
ALTER TABLE pedidos ALTER INDEX idx_pedidos_status_criado VISIBLE;

-- 16. Índice funcional (expressions).
-- o Crie índice em expressão INDEX idx_clientes_email_lower ((LOWER(email))) e otimize:
-- SELECT * FROM clientes WHERE LOWER(email) = 'joao@exemplo.com'; 17. Seletividade e cardinalidade.
-- o Use SHOW INDEX FROM ... para ver Cardinality.
-- o Compare seletividade de estado (baixa) vs documento (alta) e discuta impacto.

CREATE INDEX idx_clientes_email_lower ON clientes((LOWER(email)));

EXPLAIN SELECT * FROM clientes WHERE LOWER(email) = 'joao@exemplo.com';

-- 17. Seletividade e cardinalidade.
-- Use SHOW INDEX FROM ... para ver Cardinality.
-- Compare seletividade de estado (baixa) vs documento (alta) e discuta
-- impacto.

SHOW INDEX FROM clientes;

-- Compare cardinalidade de estado vs documento
-- Estado tem baixa cardinalidade (poucos valores distintos)
-- Documento tem alta cardinalidade (valores únicos)

-- 18. Index Merge e combinações.
-- o Crie INDEX idx_produtos_categoria (categoria) e INDEX
-- idx_produtos_preco (preco).
-- o Rode WHERE categoria='Notebook' AND preco BETWEEN ... e observe se o otimizador usa Index Merge ou prefere índice composto.
-- o Conclusão: quando preferir composto vs. múltiplos índices simples.

CREATE INDEX idx_produtos_categoria ON produtos(categoria);
CREATE INDEX idx_produtos_preco ON produtos(preco);

EXPLAIN SELECT * FROM produtos 
WHERE categoria='Notebook' AND preco BETWEEN 1000 AND 5000;

-- Conclusão: índice composto é geralmente melhor que index merge

-- 19. Manutenção e estatísticas.
-- o Execute ANALYZE TABLE e OPTIMIZE TABLE (em ambiente de teste).
-- o Observe mudanças em planos após grande carga/remoção de dados.

ANALYZE TABLE clientes, produtos, pedidos, itens_pedido;
-- Ou para tabelas específicas
OPTIMIZE TABLE pedidos;

-- 20. Trade-offs de escrita vs. leitura.
-- o Faça um benchmark simples:
-- Sem índices extras, insira 100k linhas em produtos.
-- Com vários índices novos, repita a carga.
-- o Compare tempos e explique o custo de manter muitos índices nas operações de INSERT/UPDATE/DELETE.
-- Desafios de modelagem/consulta
-- D1) Reprojetar índices para a consulta:
-- SELECT p.id, p.criado_em, c.estado, SUM(i.quantidade*i.preco_unit) AS total
-- FROM pedidos p
-- JOIN clientes c ON c.id = p.cliente_id
-- JOIN itens_pedido i ON i.pedido_id = p.id
-- WHERE c.estado = 'RS'
-- AND p.criado_em >= CURDATE() - INTERVAL 90 DAY
-- GROUP BY p.id, p.criado_em, c.estado
-- ORDER BY p.criado_em DESC
-- LIMIT 50;

-- o Objetivo: propor índices mínimos para reduzir leituras e evitar filesort.

CREATE INDEX idx_clientes_estado ON clientes(estado);
CREATE INDEX idx_pedidos_cliente_criado ON pedidos(cliente_id, criado_em);
CREATE INDEX idx_itens_pedido_pedido ON itens_pedido(pedido_id);


-- D2) Planejar índices para relatórios por mês/ano.
-- o Criar coluna gerada ano_mes (YYYYMM) e índice nela; comparar com função em coluna não indexada (DATE_FORMAT no WHERE).

-- Adicione coluna gerada
ALTER TABLE pedidos ADD COLUMN ano_mes INT GENERATED ALWAYS AS (YEAR(criado_em) * 100 + MONTH(criado_em)) STORED;

-- Crie índice
CREATE INDEX idx_pedidos_ano_mes ON pedidos(ano_mes);

-- Compare performance:
EXPLAIN SELECT * FROM pedidos WHERE ano_mes = 202401;
EXPLAIN SELECT * FROM pedidos WHERE DATE_FORMAT(criado_em, '%Y%m') = '202401';
