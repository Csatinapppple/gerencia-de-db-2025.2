USE Assinaturas;

/*1. Implemente as consultas abaixo considerando o modelo conceitual acima e utilizando para
realizar a junção SOMENTE os comandos INNER JOIN, LEFT OUTER JOIN ou RIGHT OUTER
JOIN.*/

-- a) Listar os nomes dos assinantes, seguido dos dados do endereço e os telefones correspondentes.

SELECT a.nm_assinante, e.ds_endereco, e.complemento, e.bairro, e.cep, t.ddd, t.n_fone
FROM Assinante a INNER JOIN Endereco e ON a.cd_endereco = e.cd_endereco LEFT JOIN Telefone t ON e.cd_endereco = t.cd_endereco;

-- b) Listar os nomes dos assinantes, seguido do seu ramo, ordenados por ramo e posteriormente por nome.

SELECT a.nm_assinante, r.ds_ramo
FROM Assinante a LEFT JOIN Ramo_Atividade r ON a.cd_ramo = r.cd_ramo ORDER BY r.ds_ramo, a.nm_assinante;

-- c) Listar os assinantes do município de Pelotas que são do tipo residencial.

SELECT a.nm_assinante, e.ds_endereco, m.ds_municipio, t.ds_tipo
FROM Assinante a
INNER JOIN Endereco e ON a.cd_endereco = e.cd_endereco
INNER JOIN Municipio m ON e.cd_municipio = m.cd_municipio
INNER JOIN Tipo_Assinante t ON a.cd_tipo = t.cd_tipo
WHERE m.ds_municipio = 'Pelotas' AND t.ds_tipo = 'Residencial';

-- d) Listar os nomes dos assinantes que possuem mais de um telefone.

SELECT a.nm_assinante, COUNT(t.cd_fone) AS total_telefones
FROM Assinante a
INNER JOIN Endereco e ON a.cd_endereco = e.cd_endereco
INNER JOIN Telefone t ON e.cd_endereco = t.cd_endereco
GROUP BY a.cd_assinante, a.nm_assinante HAVING COUNT(t.cd_fone) > 1;


-- e) Listar os nomes dos assinantes seguido do número do telefone, tipo de assinante comercial, com endereço em Natal ou João Câmara.

SELECT a.nm_assinante, t.ddd, t.n_fone
FROM Assinante a
INNER JOIN Endereco e ON a.cd_endereco = e.cd_endereco
INNER JOIN Municipio m ON e.cd_municipio = m.cd_municipio
INNER JOIN Tipo_Assinante ta ON a.cd_tipo = ta.cd_tipo
INNER JOIN Telefone t ON e.cd_endereco = t.cd_endereco
WHERE ta.ds_tipo = 'Comercial' AND m.ds_municipio IN ('Natal', 'João Câmara');