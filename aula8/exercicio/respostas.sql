-- 1) Auditoria de salários (UPDATE → AFTER) Objetivo: registrar mudanças de salário. Crie uma trigger que grave em uma tabela de auditoria cada alteração de salário de funcionários, guardando o salário antigo e o novo.
CREATE TRIGGER TR_Auditoria_Salario
ON Funcionario
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Sal_Func)
    BEGIN
        INSERT INTO Historico (Cod_Func, Data_Hist, Sal_Ant, Sal_Atual)
        SELECT 
            i.Cod_Func, 
            GETDATE(), 
            d.Sal_Func, 
            i.Sal_Func
        FROM inserted i
        INNER JOIN deleted d ON i.Cod_Func = d.Cod_Func
        WHERE i.Sal_Func <> d.Sal_Func;
    END
END
GO
-- 2) Impedir salário negativo (UPDATE/INSERT → BEFORE) Objetivo: validação de dados. Crie triggers que bloqueiem a inserção ou atualização de salários negativos.
CREATE TRIGGER TR_Valida_Salario
ON Funcionario
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Sal_Func < 0)
    BEGIN
        RAISERROR('Salário não pode ser negativo', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        -- Para INSERT
        INSERT INTO Funcionario (Nome_Func, Data_CadFunc, Sexo_Func, Sal_Func, End_Func)
        SELECT Nome_Func, Data_CadFunc, Sexo_Func, Sal_Func, End_Func FROM inserted
        WHERE NOT EXISTS (SELECT 1 FROM deleted) -- Apenas para INSERT
        
        -- Para UPDATE
        UPDATE f SET
            f.Nome_Func = i.Nome_Func,
            f.Data_CadFunc = i.Data_CadFunc,
            f.Sexo_Func = i.Sexo_Func,
            f.Sal_Func = i.Sal_Func,
            f.End_Func = i.End_Func
        FROM Funcionario f
        INNER JOIN inserted i ON f.Cod_Func = i.Cod_Func
        WHERE EXISTS (SELECT 1 FROM deleted) -- Apenas para UPDATE
    END
END
GO
-- 3) Carimbo de data/hora (INSERT/UPDATE → BEFORE) Objetivo: manter campos de auditoria automáticos. Crie triggers que preencham campos de data de criação e atualização
-- automaticamente.
ALTER TABLE Funcionario 
ADD Data_Criacao smalldatetime NULL,
    Data_Atualizacao smalldatetime NULL
GO

CREATE TRIGGER TR_Auditoria_Data
ON Funcionario
AFTER INSERT, UPDATE
AS
BEGIN
    -- Para novos registros (INSERT)
    UPDATE Funcionario 
    SET Data_Criacao = GETDATE(),
        Data_Atualizacao = GETDATE()
    FROM Funcionario f
    INNER JOIN inserted i ON f.Cod_Func = i.Cod_Func
    WHERE f.Data_Criacao IS NULL
    
    -- Para atualizações (UPDATE)
    UPDATE Funcionario 
    SET Data_Atualizacao = GETDATE()
    FROM Funcionario f
    INNER JOIN inserted i ON f.Cod_Func = i.Cod_Func
    WHERE EXISTS (SELECT 1 FROM deleted)
END
GO

-- 4) Contador denormalizado (INSERT/DELETE → AFTER) Objetivo: manter contagem de itens por categoria. Crie triggers que atualizem o número de itens ao inserir ou remover registros.
CREATE TRIGGER TR_Contador_Produtos
ON Produto
AFTER INSERT, DELETE
AS
BEGIN
    -- Atualizar contagem por tipo de produto
    UPDATE tp SET
        Total_Produtos = (SELECT COUNT(*) FROM Produto p WHERE p.Cod_TipoProd = tp.Cod_TipoProd)
    FROM TipoProd tp
    WHERE tp.Cod_TipoProd IN (
        SELECT Cod_TipoProd FROM inserted
        UNION
        SELECT Cod_TipoProd FROM deleted
    )
END
GO
-- 5) Soft delete + auditoria (DELETE → BEFORE & AFTER) Objetivo: evitar remoção física e auditar.

-- Crie triggers que registrem exclusões em uma tabela de backup ou auditoria.
CREATE TABLE Auditoria_Delete (
    Id_Audit int identity primary key,
    Tabela varchar(100),
    Id_Registro int,
    Dados_Excluidos varchar(max),
    Data_Exclusao smalldatetime default GETDATE(),
    Usuario varchar(100)
)
GO

ALTER TABLE Cliente ADD Ativo bit default 1
GO

CREATE TRIGGER TR_Soft_Delete_Cliente
ON Cliente
INSTEAD OF DELETE
AS
BEGIN
    -- Registrar na auditoria
    INSERT INTO Auditoria_Delete (Tabela, Id_Registro, Dados_Excluidos, Usuario)
    SELECT 'Cliente', Cod_Cli, 
           'Nome: ' + Nome_Cli + ', Renda: ' + CAST(Renda_Cli as varchar), 
           SYSTEM_USER
    FROM deleted
    
    -- Soft delete (marcar como inativo)
    UPDATE Cliente 
    SET Ativo = 0
    WHERE Cod_Cli IN (SELECT Cod_Cli FROM deleted)
END
GO
-- 6) Estoque: validação e baixa (INSERT/UPDATE → BEFORE/AFTER) Objetivo: impedir venda acima do estoque e dar baixa automaticamente. Crie triggers que validem quantidade e atualizem estoque em vendas.
CREATE TRIGGER TR_Valida_Estoque
ON Itens
INSTEAD OF INSERT
AS
BEGIN
    -- Validar estoque antes de inserir
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Produto p ON i.Cod_Prod = p.Cod_Prod
        WHERE i.Qtd_Vend > p.Qtd_EstqProd
    )
    BEGIN
        RAISERROR('Quantidade vendida maior que estoque disponível', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        -- Inserir os itens
        INSERT INTO Itens (Num_Ped, Cod_Prod, Qtd_Vend, Val_Vend)
        SELECT Num_Ped, Cod_Prod, Qtd_Vend, Val_Vend FROM inserted
        
        -- Atualizar estoque (AFTER insert)
        UPDATE p SET
            Qtd_EstqProd = p.Qtd_EstqProd - i.Qtd_Vend
        FROM Produto p
        INNER JOIN inserted i ON p.Cod_Prod = i.Cod_Prod
    END
END
GO
-- 7) Histórico de e-mail (UPDATE → AFTER) Objetivo: logar alterações de e-mail de usuários. Crie triggers que registrem alterações de e-mail em uma tabela histórica.
CREATE TABLE Historico_Email (
    Id_Hist int identity primary key,
    Cod_Cli int,
    Email_Antigo varchar(255),
    Email_Novo varchar(255),
    Data_Alteracao smalldatetime default GETDATE()
)
GO

CREATE TRIGGER TR_Historico_Email
ON EMail
AFTER UPDATE
AS
BEGIN
    IF UPDATE(EMail_Cli)
    BEGIN
        INSERT INTO Historico_Email (Cod_Cli, Email_Antigo, Email_Novo)
        SELECT 
            i.Cod_Cli,
            d.EMail_Cli,
            i.EMail_Cli
        FROM inserted i
        INNER JOIN deleted d ON i.Num_Lanc = d.Num_Lanc
        WHERE i.EMail_Cli <> d.EMail_Cli
    END
END
GO
-- 8) Normalização de caixa (INSERT/UPDATE → BEFORE) Objetivo: padronizar dados de entrada.

-- Crie triggers que convertam textos para minúsculas e eliminem espaços extras antes de salvar.
CREATE TRIGGER TR_Normaliza_Dados
ON Cliente
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    -- Para INSERT
    INSERT INTO Cliente (Cod_TipoCli, Nome_Cli, Data_CadCli, Renda_Cli, Sexo_Cli)
    SELECT Cod_TipoCli, LOWER(LTRIM(RTRIM(Nome_Cli))), Data_CadCli, Renda_Cli, Sexo_Cli
    FROM inserted
    WHERE NOT EXISTS (SELECT 1 FROM deleted)
    
    -- Para UPDATE
    UPDATE c SET
        c.Cod_TipoCli = i.Cod_TipoCli,
        c.Nome_Cli = LOWER(LTRIM(RTRIM(i.Nome_Cli))),
        c.Renda_Cli = i.Renda_Cli,
        c.Sexo_Cli = i.Sexo_Cli
    FROM Cliente c
    INNER JOIN inserted i ON c.Cod_Cli = i.Cod_Func
    WHERE EXISTS (SELECT 1 FROM deleted)
END
GO
-- 9) Restrição de horário comercial (INSERT/UPDATE → BEFORE) Objetivo: bloquear alterações fora do horário. Crie triggers que impeçam modificações entre 18h e 8h.
CREATE TRIGGER TR_Horario_Comercial
ON Pedido
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    DECLARE @HoraAtual int = DATEPART(HOUR, GETDATE())
    
    IF @HoraAtual < 8 OR @HoraAtual >= 18
    BEGIN
        RAISERROR('Operações permitidas apenas entre 8h e 18h', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        -- Permite a operação normal
        INSERT INTO Pedido (Cod_Cli, Cod_Func, Cod_Sta, Data_Ped, Val_Ped)
        SELECT Cod_Cli, Cod_Func, Cod_Sta, Data_Ped, Val_Ped FROM inserted
        WHERE NOT EXISTS (SELECT 1 FROM deleted)
        
        UPDATE p SET
            p.Cod_Cli = i.Cod_Cli,
            p.Cod_Func = i.Cod_Func,
            p.Cod_Sta = i.Cod_Sta,
            p.Data_Ped = i.Data_Ped,
            p.Val_Ped = i.Val_Ped
        FROM Pedido p
        INNER JOIN inserted i ON p.Num_Ped = i.Num_Ped
        WHERE EXISTS (SELECT 1 FROM deleted)
    END
END
GO
-- 10) Proibir atualização que reduza nota (UPDATE → BEFORE) Objetivo: impedir que notas sejam diminuídas. Crie triggers que só permitam aumento ou manutenção de nota, nunca diminuição.
CREATE TRIGGER TR_Proibe_Reducao_Nota
ON Pontuacao
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN deleted d ON i.Num_Lanc = d.Num_Lanc
        WHERE i.Pto_Func < d.Pto_Func
    )
    BEGIN
        RAISERROR('Não é permitido reduzir a pontuação do funcionário', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        UPDATE p SET
            p.Cod_Func = i.Cod_Func,
            p.Data_Pto = i.Data_Pto,
            p.Pto_Func = i.Pto_Func
        FROM Pontuacao p
        INNER JOIN inserted i ON p.Num_Lanc = i.Num_Lanc
    END
END
GO