CREATE DATABASE IF NOT EXISTS loja;

CREATE TABLE
    clientes (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        nome VARCHAR(120) NOT NULL,
        email VARCHAR(160) NOT NULL UNIQUE,
        documento CHAR(11) NOT NULL, -- CPF sem pontuação cidade VARCHAR(80),
        estado CHAR(2),
        criado_em DATETIME NOT NULL,
        INDEX idx_clientes_estado (estado)
    ) ENGINE = InnoDB;

CREATE TABLE
    produtos (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        sku VARCHAR(32) NOT NULL UNIQUE,
        nome VARCHAR(160) NOT NULL,
        categoria VARCHAR(80),
        preco DECIMAL(10, 2) NOT NULL,
        ativo TINYINT (1) NOT NULL DEFAULT 1,
        FULLTEXT INDEX ftx_produtos_nome (nome) -- se usar InnoDB 5.6+ / 8.0+
    ) ENGINE = InnoDB;

CREATE TABLE
    pedidos (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        cliente_id BIGINT NOT NULL,
        status ENUM ('NOVO', 'PAGO', 'ENVIADO', 'CANCELADO') NOT NULL,
        criado_em DATETIME NOT NULL,
        total DECIMAL(12, 2) NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id),
        INDEX idx_pedidos_cliente (cliente_id),
        INDEX idx_pedidos_status_criado (status, criado_em)
    ) ENGINE = InnoDB;

CREATE TABLE
    itens_pedido (
        pedido_id BIGINT NOT NULL,
        produto_id BIGINT NOT NULL,
        quantidade INT NOT NULL,
        preco_unit DECIMAL(10, 2) NOT NULL,
        PRIMARY KEY (pedido_id, produto_id),
        FOREIGN KEY (pedido_id) REFERENCES pedidos (id),
        FOREIGN KEY (produto_id) REFERENCES produtos (id),
        INDEX idx_item_produto (produto_id)
    ) ENGINE = InnoDB;