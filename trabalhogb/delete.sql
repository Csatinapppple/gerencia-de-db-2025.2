START TRANSACTION;
DELETE FROM pagamentos
WHERE status != 'pago';
COMMIT;
