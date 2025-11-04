CREATE FUNCTION calcular_saldo_restante(consulta_id_param INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE valor_total_consulta DECIMAL(10,2);
    DECLARE total_pago DECIMAL(10,2);
    DECLARE saldo_restante DECIMAL(10,2);
    
    -- Pega o valor total da consulta
    SELECT valor_total INTO valor_total_consulta 
    FROM consultas 
    WHERE id = consulta_id_param;
    
    -- Pega o valor total ja pago
    SELECT COALESCE(SUM(valor), 0) INTO total_pago 
    FROM pagamentos 
    WHERE consulta_id = consulta_id_param 
    AND status = 'pago';
    
    SET saldo_restante = valor_total_consulta - total_pago;
    
    IF saldo_restante < 0 THEN
        SET saldo_restante = 0;
    END IF;
    
    RETURN saldo_restante;
END;

CREATE TRIGGER before_insert_pagamento
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
END;


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
END;
