START TRANSACTION;
USE clinica_vet;
DELETE FROM pagamentos
WHERE status != 'pago';
COMMIT;
