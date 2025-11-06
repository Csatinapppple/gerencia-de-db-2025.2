USE clinica_vet;

-- 1. Listar todos os clientes cadastrados (nome, telefone, email), ordenados por nome.
SELECT nome, telefone, email 
FROM clientes
ORDER BY nome;

-- 2. Listar todos os animais atendidos (nome, espécie, raça, data nascimento), ordenados por espécie e nome.
SELECT nome, especie, raca, dt_nascimento
FROM animais
ORDER BY especie, nome;

-- 3. Mostrar todos os agendamentos de consultas para uma data específica (animal, tutor, horário).
SELECT 
    an.nome,
    cl.nome, 
    DATE(co.data_hora) AS data_consulta
FROM consultas co
INNER JOIN animais an on co.animal_id = an.id
INNER JOIN clientes cl on an.cliente_id = cl.id
WHERE DATE(co.data_hora) = '2023-06-10';

-- 4. Listar todos os veterinários (nome, especialidade, registro), ordenados por especialidade.
SELECT
    nome, especialidade, registro_prof as registro
FROM veterinarios
ORDER BY especialidade;

-- 5. Mostrar animais de uma espécie específica (nome, raça, tutor).
SELECT
    a.nome, a.raca, c.nome AS dono
FROM animais a
INNER JOIN clientes c 
ON a.cliente_id = c.id
WHERE a.especie = 'Cachorro';

-- 6. Listar clientes com mais de um animal (nome, quantidade).
SELECT 
    c.nome, COUNT(a.cliente_id) AS quantidade
FROM clientes c
INNER JOIN animais a
ON c.id = a.cliente_id
GROUP BY c.id, c.nome
HAVING COUNT(a.cliente_id) > 1;

-- 7. Listar consultas realizadas em intervalo de datas (data, animal, veterinário, procedimento).
SELECT
    DATE(co.data_hora) AS data,
    an.nome AS nome_animal,
    vet.nome AS nome_veterinario,
    pro.nome AS procedimento
FROM consultas co
INNER JOIN veterinarios vet
ON co.veterinario_id = vet.id
INNER JOIN animais an
ON co.animal_id = an.id
INNER JOIN consulta_procedimentos co_pro
ON co.id = co_pro.consulta_id
INNER JOIN procedimentos pro
ON co_pro.procedimento_id = pro.id 
WHERE DATE(co.data_hora) BETWEEN '2023-06-10' AND '2023-06-11'
    AND co.status = 'realizada';

-- 8. Listar medicamentos mais prescritos (nome, total prescrições), ordem decrescente.
SELECT
    med.nome,
    SUM(pre.quantidade) as total_prescricoes
FROM prescricoes pre
INNER JOIN medicamentos med 
ON med.id = pre.medicamento_id
GROUP BY med.id, med.nome
ORDER BY total_prescricoes DESC;

-- 9. Consultas realizadas por um veterinário específico (data, animal, tutor).
SELECT 
    con.data_hora AS data,
    an.nome AS nome_animal,
    cl.nome AS dono
FROM veterinarios vet
INNER JOIN consultas con
ON vet.id = con.veterinario_id
INNER JOIN animais an
ON an.id = con.animal_id
INNER JOIN clientes cl
ON cl.id = an.cliente_id
WHERE vet.nome LIKE '%Roberto Almeida%';

-- 10. Listar procedimentos disponíveis (nome, tipo, valor), ordenados por tipo e nome.
SELECT nome, tipo, valor_base AS valor
FROM procedimentos
WHERE ativo = 1
ORDER BY tipo, nome;

-- 11. Animais com consultas agendadas para próxima semana (nome, data/hora, tutor).
SELECT 
    an.nome as nome_animal,
    con.data_hora,
    cli.nome as cliente
FROM animais an
INNER JOIN consultas con 
ON an.id = con.animal_id
INNER JOIN clientes cli 
ON an.cliente_id = cli.id
WHERE DATE(con.data_hora) BETWEEN 
    CURDATE() + INTERVAL 7 DAY AND 
    CURDATE() + INTERVAL 13 DAY
    AND con.status != 'cancelada';

-- 12. Clientes sem consultas registradas (nome, telefone).
SELECT 
    cl.nome,
    cl.telefone
FROM clientes cl
LEFT JOIN animais an ON cl.id = an.cliente_id
LEFT JOIN consultas co ON an.id = co.animal_id
WHERE co.id IS NULL;

-- 13. Histórico de consultas de um animal específico (data, veterinário, procedimento, observações).
SELECT
    co.data_hora,
    vet.nome AS veterinario,
    pro.nome AS procedimento,
    co.observacoes
FROM animais an
INNER JOIN consultas co
ON an.id = co.animal_id
INNER JOIN veterinarios vet
ON co.veterinario_id = vet.id
INNER JOIN consulta_procedimentos co_pro
ON co.id = co_pro.consulta_id
INNER JOIN procedimentos pro
ON pro.id = co_pro.procedimento_id
WHERE an.nome LIKE '%Rex%';

-- 14. Raças mais comuns atendidas (raça, quantidade).
SELECT
    raca,
    COUNT(raca) AS qtd
FROM animais
WHERE raca IS NOT NULL
GROUP BY raca
ORDER BY qtd DESC;

-- 15. Agendamentos cancelados no último mês (data, animal, motivo).
SELECT 
    DATE(con.data_hora) as data,
    an.nome AS animal,
    con.motivo_cancelamento AS motivo
FROM consultas con
INNER JOIN animais an
ON con.animal_id = an.id
WHERE con.status = 'cancelada'
    AND con.data_hora >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01')
    AND con.data_hora < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01');

-- 16. Faturamento total por mês (mês/ano, total).
SELECT
    DATE_FORMAT(p.data_pagto, '%Y-%m') AS mes_ano,
    SUM(p.valor) AS faturamento_total
FROM pagamentos p
WHERE p.status = 'pago'
    AND YEAR(p.data_pagto) = 2023
GROUP BY DATE_FORMAT(p.data_pagto, '%Y-%m')
ORDER BY mes_ano;

-- 17. Clientes aniversariantes do mês atual (nome, data nascimento, telefone).
SELECT 
    nome,
    dt_nascimento,
    telefone
FROM clientes
WHERE MONTH(dt_nascimento) = MONTH(CURRENT_DATE);

-- 18. Animais que nunca realizaram procedimento cirúrgico (nome, espécie, tutor).
SELECT 
    an.nome,
    an.especie,
    cli.nome as tutor
FROM animais an
INNER JOIN clientes cli ON an.cliente_id = cli.id
WHERE an.id NOT IN (
    SELECT DISTINCT an2.id
    FROM animais an2
    INNER JOIN consultas con ON an2.id = con.animal_id
    INNER JOIN consulta_procedimentos con_pro ON con.id = con_pro.consulta_id
    INNER JOIN procedimentos pro ON con_pro.procedimento_id = pro.id
    WHERE pro.tipo = 'cirurgico'
);

-- 19. Última consulta realizada por cada animal (nome, data, veterinário).
SELECT
    an.nome as animal,
    MAX(con.data_hora) as data,
    vet.nome as veterinario
FROM animais an
INNER JOIN consultas con ON an.id = con.animal_id
INNER JOIN veterinarios vet ON con.veterinario_id = vet.id
WHERE con.status = 'realizada'
GROUP BY an.id, an.nome, vet.nome;

-- 20. Veterinários que realizaram mais de X consultas no mês passado (nome, quantidade).
-- Substitua X pelo número desejado (exemplo: 5)
SELECT
    vet.nome as veterinario,
    COUNT(con.id) as quantidade
FROM consultas con
INNER JOIN veterinarios vet ON con.veterinario_id = vet.id
WHERE con.status = 'realizada'
    AND con.data_hora >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01')
    AND con.data_hora < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
GROUP BY vet.id, vet.nome
HAVING COUNT(con.id) > 5;  -- Altere 5 para o valor desejado

-- Consulta para ver atendimentos realizados
SELECT 
    c.id as consulta_id,
    a.nome as animal,
    cl.nome as dono,
    v.nome as veterinario,
    c.data_hora,
    c.valor_total
FROM consultas c
JOIN animais a ON c.animal_id = a.id
JOIN clientes cl ON a.cliente_id = cl.id
JOIN veterinarios v ON c.veterinario_id = v.id
WHERE c.status = 'realizada'
ORDER BY c.data_hora DESC;

-- Faturamento por veterinário
SELECT 
    v.nome as veterinario,
    COUNT(c.id) as total_consultas,
    SUM(c.valor_total) as faturamento_total
FROM consultas c
JOIN veterinarios v ON c.veterinario_id = v.id
WHERE c.status = 'realizada'
GROUP BY v.id, v.nome
ORDER BY faturamento_total DESC;
