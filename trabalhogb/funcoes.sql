USE clinica_vet;

DROP FUNCTION IF EXISTS calcular_saldo_restante;

CREATE FUNCTION calcular_saldo_restante(consulta_id_param INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
RETURN (
    SELECT COALESCE(
        GREATEST(c.valor_total - SUM(p.valor), 0),
        c.valor_total
    )
    FROM consultas c
    LEFT JOIN pagamentos p ON c.id = p.consulta_id AND p.status = 'pago'
    WHERE c.id = consulta_id_param
    GROUP BY c.id, c.valor_total
);

DELIMITER ;

--#BEGIN
DELIMITER //
CREATE TRIGGER before_insert_pagamentos
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
	DECLARE saldo_restante DECIMAL(10,2);

	IF NEW.status = 'pago' THEN
		SET saldo_restante = calcular_saldo_restante(NEW.consulta_id);
        
		IF NEW.valor > saldo_restante THEN
			-- se o valor for maior que o restante então vai se acumular no restante
			SET NEW.valor = saldo_restante;
		END IF;
	END IF;
END//
DELIMITER ;
--#END

--#BEGIN
DELIMITER //
CREATE TRIGGER before_update_pagamento
BEFORE UPDATE ON pagamentos
FOR EACH ROW
BEGIN
    DECLARE saldo_restante DECIMAL(10,2);
    -- Somente atualiza se a mudanca for de status não 'pago' para 'pago'
    IF NEW.status = 'pago' AND OLD.status != 'pago' THEN
        SET saldo_restante = calcular_saldo_restante(NEW.consulta_id);
        
        IF NEW.valor > saldo_restante THEN
			-- se o valor for maior que o restante então vai se acumular no restante
            SET NEW.valor = saldo_restante;
        END IF;
    END IF;
END//
DELIMITER ;
--#END

-- Teste dos triggers
INSERT INTO clinica_vet.consultas
(animal_id, veterinario_id, data_hora, status, valor_total)
VALUES(1, 1, CURRENT_TIMESTAMP, 'realizada', 70.00);

INSERT INTO clinica_vet.pagamentos 
(consulta_id, data_pagto , metodo , status , valor)
VALUES (7, CURRENT_TIMESTAMP, 'pix', 'pago', 100.00)

INSERT INTO clinica_vet.pagamentos 
(consulta_id, data_pagto , metodo , status , valor)
VALUES (8, CURRENT_TIMESTAMP, 'pix', 'pendente', 100.00)

UPDATE clinica_vet.pagamentos p
SET p.status = 'pago'
WHERE p.id = 7;
