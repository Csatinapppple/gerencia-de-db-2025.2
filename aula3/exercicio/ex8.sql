--8) Criar VIEW de faturamento por pedido.
CREATE VIEW vw_pedido_total AS
SELECT
	p.id AS pedido_id,
	c.nome AS nome,
	sum(pi.qtd) AS itens,
	sum(pi.qtd * pi.preco_unit) AS total_bruto,
	p.status
FROM pedidos p 
INNER JOIN pedido_itens pi ON p.id = pi.pedido_id
INNER JOIN clientes c ON p.cliente_id = c.id
GROUP BY pedido_id;
