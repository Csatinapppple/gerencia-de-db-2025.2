--4) Criar índice composto em `pedido_itens` (por produto e qtd).
CREATE INDEX ix_pi_prod_qtd ON pedido_itens (produto_id, qtd);
