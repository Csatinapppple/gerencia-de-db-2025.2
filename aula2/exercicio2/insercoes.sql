BEGIN TRANSACTION;

INSERT INTO clientes (nome, email, telefone, dt_nascimento) VALUES
('Maria Silva', 'maria.silva@email.com', '(11) 98765-4321', '1985-03-15'),
('João Santos', 'joao.santos@email.com', '(21) 99876-5432', '1990-07-22'),
('Ana Oliveira', 'ana.oliveira@email.com', '(31) 98765-1234', '1978-11-30'),
('Carlos Pereira', 'carlos.pereira@email.com', '(41) 91234-5678', '1982-05-10'),
('Juliana Costa', 'juliana.costa@email.com', '(51) 92345-6789', '1995-09-18');

INSERT INTO veterinarios (nome, especialidade, registro_prof, email, telefone) VALUES
('Dr. Roberto Almeida', 'Clínico Geral', 'CRMV-SP 12345', 'roberto.almeida@vet.com', '(11) 91234-5678'),
('Dra. Fernanda Lima', 'Cirurgia', 'CRMV-RJ 54321', 'fernanda.lima@vet.com', '(21) 92345-6789'),
('Dr. Marcelo Souza', 'Dermatologia', 'CRMV-MG 67890', 'marcelo.souza@vet.com', '(31) 93456-7890'),
('Dra. Patricia Rocha', 'Ortopedia', 'CRMV-PR 09876', 'patricia.rocha@vet.com', '(41) 94567-8901');

INSERT INTO animais (nome, especie, raca, sexo, dt_nascimento, cliente_id) VALUES
('Rex', 'Cachorro', 'Labrador', 'M', '2020-01-15', 1),
('Luna', 'Gato', 'Siamês', 'F', '2019-05-20', 1),
('Thor', 'Cachorro', 'Bulldog Francês', 'M', '2021-03-10', 2),
('Mimi', 'Gato', 'Persa', 'F', '2018-11-05', 3),
('Bobby', 'Cachorro', 'Golden Retriever', 'M', '2019-07-12', 4),
('Nina', 'Cachorro', 'Poodle', 'F', '2020-09-25', 5);

INSERT INTO procedimentos (nome, tipo, valor_base) VALUES
('Consulta Clínica', 'consulta', 150.00),
('Vacina Antirrábica', 'vacina', 80.00),
('Vacina V10', 'vacina', 120.00),
('Hemograma Completo', 'exame', 90.00),
('Ultrassom Abdominal', 'exame', 250.00),
('Castração', 'cirurgico', 400.00),
('Limpeza Dentária', 'cirurgico', 200.00),
('Consulta Emergencial', 'consulta', 250.00);

INSERT INTO medicamentos (nome, descricao, concentracao, unidade) VALUES
('Antibiótico Pet', 'Antibiótico de amplo espectro', '50mg', 'comprimido'),
('Analgésico Vet', 'Alívio de dor pós-operatória', '25mg', 'comprimido'),
('Vermífugo Max', 'Tratamento de verminoses', '100mg/ml', 'solução oral'),
('Anti-inflamatório Can', 'Para inflamações articulares', '20mg', 'comprimido'),
('Shampoo Dermatológico', 'Para problemas de pele', NULL, 'frasco 200ml');

INSERT INTO consultas (animal_id, veterinario_id, data_hora, status, observacoes, valor_total) VALUES
(1, 1, '2023-06-10 09:00:00', 'realizada', 'Animal com febre e falta de apetite', 230.00),
(2, 2, '2023-06-10 10:30:00', 'realizada', 'Vacinação anual', 200.00),
(3, 1, '2023-06-11 14:00:00', 'realizada', 'Check-up anual', 150.00),
(4, 3, '2023-06-12 11:00:00', 'cancelada', 'Cliente desistiu', 0.00),
(5, 4, '2023-06-13 16:30:00', 'agendada', NULL, 0.00),
(1, 2, '2023-06-15 08:00:00', 'realizada', 'Castração realizada com sucesso', 400.00);

INSERT INTO consulta_procedimentos (consulta_id, procedimento_id, quantidade, valor_unit) VALUES
(1, 1, 1, 150.00), -- Consulta Clínica
(1, 4, 1, 80.00),  -- Hemograma
(2, 2, 1, 80.00),  -- Vacina Antirrábica
(2, 3, 1, 120.00), -- Vacina V10
(3, 1, 1, 150.00), -- Consulta Clínica
(6, 6, 1, 400.00); -- Castração

INSERT INTO prescricoes (consulta_id, medicamento_id, quantidade, posologia) VALUES
(1, 1, 10, '1 comprimido a cada 12 horas por 5 dias'),
(1, 3, 1, 'Aplicar 2ml em dose única'),
(6, 2, 5, '1 comprimido a cada 24 horas por 5 dias'),
(6, 4, 5, '1 comprimido a cada 24 horas por 5 dias');

INSERT INTO pagamentos (consulta_id, data_pagto, valor, metodo, status) VALUES
(1, '2023-06-10 10:30:00', 230.00, 'credito', 'pago'),
(2, '2023-06-10 11:00:00', 200.00, 'debito', 'pago'),
(3, '2023-06-11 15:00:00', 150.00, 'pix', 'pago'),
(6, '2023-06-15 10:00:00', 400.00, 'dinheiro', 'pago');


COMMIT;
