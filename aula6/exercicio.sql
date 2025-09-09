
-- 1.
-- a)
SELECT 
	a.nm_assinante,
	en.ds_endereco as Endereco,
	en.complemento as Complemento,
	en.bairro as Bairro,
	en.CEP as CEP,
	tel.n_fone as Telefone,
	tel.ddd as DDD
FROM Assinante a
INNER JOIN Endereco en
ON a.id = en.assinante_id
LEFT OUTER JOIN Telefone tel
ON en.id = tel.endereco_id;

-- b)
SELECT 
	ass.nome, ra.ds_ramo
FROM Assinante ass
LEFT OUTER JOIN Ramo_Atividade ra
ON ass.ramo_atividade_id = ra.id
ORDER BY ra.ds_ramo, ass.nome;

--c)
SELECT
	ass.nm_assinante
FROM Assinante ass
INNER JOIN Endereco en
ON ass.id = en.assinante_id
INNER JOIN Municipio mu
ON en.municipio_id = mu.id
INNER JOIN Tipo_Assinante ti_ass
ON ass.tipo_assinante_id = ti_ass.id
WHERE mu.ds_municipio LIKE 'Pelotas'
	AND ti_ass.ds_tipo LIKE 'residencial';

--d)
SELECT 
	ass.nm_assinante AS nome
FROM Assinante ass
INNER JOIN Endereco en
ON ass.endereco_id = en.id
INNER JOIN Telefone tel
ON en.id - tel.endereco_id
GROUP BY nome
HAVING COUNT(tel.n_fone) > 1;

--e)

SELECT
	ass.nm_assinante,
	tel.ddd,
	tel.n_fone
FROM Assinante ass
INNER JOIN Endereco en ON ass.endereco_id = en.id
INNER JOIN Municipio mun ON en.municipio_id = mu.id
INNER JOIN Tipo_Assinante ti_ass ON ass.tipo_assinante_id = ti_ass.id


--2.
--a)
SELECT 
	v.placa,
	c.nome
FROM Veiculo v
INNER JOIN Cliente c
ON v.cliente_cpf = c.cpf;


--b)
SELECT c.cpf, c.nome
FROM Cliente c
INNER JOIN Veículo v ON c.cpf = v.Cliente_cpf
WHERE v.placa = 'JJJ-2020';

--c)
SELECT v.placa, v.cor
FROM Veículo v
INNER JOIN Estaciona e ON v.placa = e.Veículo_placa
WHERE e.cod = 1;

--d)
SELECT v.placa, v.ano
FROM Veículo v
INNER JOIN Estaciona e ON v.placa = e.Veículo_placa
WHERE e.cod = 1;

--e)
SELECT v.placa, v.ano, m.Desc_2
FROM Veículo v
INNER JOIN Modelo m ON v.Modelo_codMod = m.codMod
WHERE v.ano >= 2000;

--f)
SELECT p.ender, e.dtEntrada, e.dtSaida
FROM Estaciona e
INNER JOIN Patio p ON e.Patio_num = p.num
WHERE e.Veículo_placa = 'JEG-1010';

--g)
SELECT COUNT(*) as quantidade
FROM Estaciona e
INNER JOIN Veículo v ON e.Veículo_placa = v.placa
WHERE v.cor = 'verde';

--h)
SELECT c.*
FROM Cliente c
INNER JOIN Veículo v ON c.cpf = v.Cliente_cpf
WHERE v.Modelo_codMod = 1;

--i)
SELECT v.placa, e.hrEntrada, e.hrSaida
FROM Veículo v
INNER JOIN Estaciona e ON v.placa = e.Veículo_placa
WHERE v.cor = 'verde';

--j)
SELECT e.*
FROM Estaciona e
WHERE e.Veículo_placa = 'JJJ-2020';

--k)
SELECT c.nome
FROM Cliente c
INNER JOIN Veículo v ON c.cpf = v.Cliente_cpf
INNER JOIN Estaciona e ON v.placa = e.Veículo_placa
WHERE e.cod = 2;

--l)
SELECT c.cpf
FROM Cliente c
INNER JOIN Veículo v ON c.cpf = v.Cliente_cpf
INNER JOIN Estaciona e ON v.placa = e.Veículo_placa
WHERE e.cod = 3;

--m)
SELECT m.Desc_2
FROM Modelo m
INNER JOIN Veículo v ON m.codMod = v.Modelo_codMod
INNER JOIN Estaciona e ON v.placa = e.Veículo_placa
WHERE e.cod = 2;

--n)
SELECT v.placa, c.nome, m.Desc_2
FROM Veículo v
INNER JOIN Cliente c ON v.Cliente_cpf = c.cpf
INNER JOIN Modelo m ON v.Modelo_codMod = m.codMod;
