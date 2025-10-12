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

-- Additional Categories
INSERT INTO categories VALUES 
(6,'Brinquedos'),
(7,'Beleza'),
(8,'Automotivo'),
(9,'Ferramentas'),
(10,'Alimentação');

-- Additional Products
INSERT INTO products VALUES
(103,'Tablet Vision Pro',1,3499.90,'2025-02-20 14:00:00'),
(104,'Smartwatch Fitness Pro',1,899.90,'2025-01-25 11:30:00'),
(202,'Livro Python Avançado',2,129.90,'2025-02-15 16:45:00'),
(203,'Livro Data Science',2,159.90,'2025-03-01 10:20:00'),
(301,'Panela de Pressão 5L',3,189.90,'2024-11-20 08:15:00'),
(302,'Conjunto de Facas Profissional',3,299.90,'2024-12-05 13:40:00'),
(401,'Bola de Futebol Oficial',4,79.90,'2025-01-08 15:25:00'),
(402,'Tênis de Corrida Pro',4,399.90,'2025-02-28 09:10:00'),
(501,'Camiseta Básica Algodão',5,29.90,'2024-10-15 11:00:00'),
(601,'Quebra-Cabeça 1000 peças',6,49.90,'2025-03-10 14:30:00');

-- Additional Customers
INSERT INTO customers VALUES
(3,'Carla Mendes','carla.mendes@example.com','Rio de Janeiro','RJ','2025-01-20 11:45:00'),
(4,'Diego Santos','diego.santos@example.com','Belo Horizonte','MG','2025-02-05 16:30:00'),
(5,'Eduarda Costa','eduarda.costa@example.com','Florianópolis','SC','2025-02-28 10:15:00'),
(6,'Fernando Oliveira','fernando.oliveira@example.com','Curitiba','PR','2025-03-12 14:20:00');

-- Additional Orders
INSERT INTO orders VALUES 
(1002,2,'2025-03-16 14:30:00','Processing',NULL,'QuickDeliver',25.00),
(1003,3,'2025-03-14 09:15:00','Delivered','2025-03-15 16:45:00','FastShip',42.75),
(1004,1,'2025-03-17 11:20:00','Shipped','2025-03-18 08:30:00','QuickDeliver',38.90),
(1005,4,'2025-03-18 16:45:00','Processing',NULL,'FastShip',29.99),
(1006,5,'2025-03-12 13:10:00','Delivered','2025-03-13 14:20:00','QuickDeliver',45.25);

-- Order Items
INSERT INTO order_items VALUES
(1001,101,1,1999.90,0.00),
(1001,102,2,299.00,0.10),
(1002,201,1,99.90,0.05),
(1002,501,3,29.90,0.15),
(1003,103,1,3499.90,0.00),
(1003,302,1,299.90,0.20),
(1004,104,1,899.90,0.00),
(1004,401,2,79.90,0.00),
(1005,202,2,129.90,0.10),
(1005,601,1,49.90,0.00),
(1006,301,1,189.90,0.05),
(1006,402,1,399.90,0.00);

-- Departments
INSERT INTO departments VALUES
(1,'TI'),
(2,'Vendas'),
(3,'Marketing'),
(4,'RH'),
(5,'Financeiro'),
(6,'Operações');

-- Employees
INSERT INTO employees VALUES
(1,'João','Silva',1,'2020-05-15',7500.00,NULL),
(2,'Maria','Santos',2,'2019-08-20',5200.00,1),
(3,'Pedro','Oliveira',1,'2021-03-10',6800.00,1),
(4,'Ana','Costa',3,'2022-01-08',4800.00,1),
(5,'Carlos','Rocha',2,'2020-11-30',5500.00,1),
(6,'Juliana','Ferreira',4,'2023-06-15',4200.00,1),
(7,'Ricardo','Almeida',5,'2018-09-25',8200.00,NULL),
(8,'Patrícia','Lima',6,'2022-07-12',4700.00,7);

-- Attendance
INSERT INTO attendance VALUES
(1,1,'2025-03-17','08:00:00','17:00:00'),
(2,2,'2025-03-17','08:15:00','17:30:00'),
(3,3,'2025-03-17','08:05:00','17:15:00'),
(4,4,'2025-03-17','09:00:00','18:00:00'),
(5,5,'2025-03-17','08:20:00','17:45:00'),
(6,1,'2025-03-18','08:10:00','17:10:00'),
(7,2,'2025-03-18','08:25:00','17:35:00'),
(8,3,'2025-03-18','08:00:00','17:20:00');

-- Payments
INSERT INTO payments VALUES
(1,1,'2025-03-15',2034.40,'Cartão de Crédito'),
(2,2,'2025-03-16',138.71,'PIX'),
(3,3,'2025-03-14',3799.82,'Cartão de Débito'),
(4,1,'2025-03-17',1058.70,'Cartão de Crédito'),
(5,4,'2025-03-18',283.72,'PIX'),
(6,5,'2025-03-12',589.75,'Boleto');

-- Reviews
INSERT INTO reviews VALUES
(1,101,1,5,'Excelente smartphone, muito rápido!','2025-03-20'),
(2,102,1,4,'Bom fone, qualidade de som ótima','2025-03-19'),
(3,201,2,5,'Livro essencial para aprender SQL','2025-03-18'),
(4,103,3,5,'Tablet incrível, tela de alta qualidade','2025-03-17'),
(5,302,3,4,'Facas muito afiadas, bom custo-benefício','2025-03-16'),
(6,104,1,3,'Bom smartwatch, mas a bateria poderia ser melhor','2025-03-15'),
(7,501,2,5,'Camisetas confortáveis e duráveis','2025-03-14'),
(8,401,1,4,'Bola de boa qualidade, ótima para treinos','2025-03-13');
