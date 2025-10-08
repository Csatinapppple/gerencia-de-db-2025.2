-- Categorias
INSERT INTO categories VALUES (1,'Eletrônicos'),(2,'Livros'),(3,'Casa & Cozinha'),(4,'Esporte'),(5,'Vestuário');

-- Produtos
INSERT INTO products VALUES
(101,'Smartphone Delta X',1,1999.90,'2024-11-01 10:00:00'), (102,'Fone Bluetooth Wave',1,299.00,'2025-01-15 09:30:00'), (201,'Livro SQL Essencial',2,99.90,'2024-12-10 11:05:00');

-- Clientes
INSERT INTO customers VALUES
(1,'Ana Souza','ana.souza@example.com','Porto Alegre','RS','2024-12-01 09:00:00'), (2,'Bruno Lima','bruno.lima@example.com','São Paulo','SP','2025-01-10 15:20:00');

-- Pedidos (exemplo)
INSERT INTO orders VALUES (1001,1,'2025-03-15 10:15:00','Shipped','2025-03-16 09:00:00','FastShip',35.50);
