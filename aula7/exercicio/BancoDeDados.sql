CREATE DATABASE ProjetoDI
GO
USE ProjetoDI
GO

CREATE TABLE Pessoa
(
  IDPessoa int IDENTITY (1,1) NOT NULL,
  Nome varchar(50) NULL,
  DataNascimento datetime NULL,
  Sexo char(1) NULL,
  CONSTRAINT PK_Pessoa PRIMARY KEY CLUSTERED (IDPessoa ASC)
)
CREATE TABLE Revista 
(
   RevistaID CHAR(10) not null primary key,
   Titulo varchar(30) not null,
   Ano tinyint not null,
   Edicao tinyint not null,
   Capa varchar(35) not null,
   Publicador varchar(30) not null,
   Valor decimal(12,2)
) 
GO

CREATE TABLE Sumario
(
  SumarioID int identity(1,1) not null primary key,
  RevistaID char(10),
  Artigo varchar(50) not null,
  Pagina tinyint not null,
  Constraint fk_RevSum FOREIGN KEY (RevistaID) REFERENCES Revista(RevistaID)
)
GO

CREATE TABLE Artigo
(
  ArtigoID int identity(1,1) not null primary key,
  TituloArtigo varchar(50) not null,
  Subtitulo varchar(35),
  Resumo text
)
GO

CREATE TABLE RevistaArtigo
(
   RevistaID Char(10),
   ArtigoID int,
   Constraint FK_REVRevArtigo FOREIGN KEY (RevistaID) REFERENCES Revista(RevistaID),
   Constraint FK_ArtRevistaArtigo FOREIGN KEY (ArtigoID) REFERENCES Artigo(ArtigoID) 
)
GO
---Tabela Pessoa
CREATE PROCEDURE uspCadastrarPessoa
@Excluir AS BIT = NULL,
@IDPessoa AS INT = NULL,
@Nome AS VARCHAR(50) = NULL,
@DataNascimento AS DATETIME = NULL,
@Sexo AS CHAR(1) = NULL
AS
BEGIN
    SET NOCOUNT ON
   BEGIN TRY
      BEGIN TRAN
      IF (@Excluir = 1)
         BEGIN
             DELETE FROM Pessoa WHERE IDPessoa = @IDPessoa 
         END
      ELSE IF (@IDPessoa IS NULL)
         BEGIN
             INSERT INTO Pessoa (Nome, DataNascimento, Sexo) VALUES (@Nome,@DataNascimento,@Sexo)
         END
      ELSE
         BEGIN
             UPDATE Pessoa SET  Nome = @Nome,
                                DataNascimento = @DataNascimento,
                                Sexo  = @Sexo
                     WHERE IDPessoa  = @IDPessoa 
          END
          COMMIT TRAN
   END TRY
   BEGIN CATCH
      ROLLBACK TRAN
      SELECT ERROR_MESSAGE() AS Retorno
   END CATCH
   RETURN
END
GO

CREATE PROCEDURE uspConsultarPessoa
@IDPessoa AS INT = NULL,
@Nome AS VARCHAR(50) = NULL,
@DataNascimento AS DATETIME = NULL,
@Sexo AS CHAR(1) = NULL
AS
BEGIN
SELECT IDPessoa, Nome, DataNascimento, Sexo,
       CASE WHEN Sexo = 'F' THEN 'FEMININO' ELSE 'MASCULINO' END AS SexoDesc 
FROM Pessoa 
WHERE ((IDPessoa = @IDPessoa) OR (@IDPessoa IS NULL)) AND
      ((Nome LIKE '%' + @Nome + '%') OR (@Nome IS NULL)) AND
      ((DataNascimento = @DataNascimento) OR ( @DataNascimento IS NULL)) AND
      ((Sexo = @Sexo) OR (@Sexo IS NULL)) AND
      ((@IDPessoa IS NOT NULL)OR(@Nome IS NOT NULL) OR (@DataNascimento IS NOT NULL)OR(@Sexo IS NOT NULL))
END

-----------------------------------------------------------------------------------
CREATE PROCEDURE uspCadastrarRevista
@Excluir AS BIT = NULL,
@RevistaID AS CHAR(10) = NULL,
@Titulo AS VARCHAR(30) = NULL,
@Ano AS TINYINT = NULL,
@Edicao AS TINYINT = NULL,
@Capa AS VARCHAR(35) = NULL,
@Publicador AS VARCHAR(30) = NULL,
@Valor AS DECIMAL(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON
   BEGIN TRY
      BEGIN TRAN
      IF (@Excluir = 1)
         BEGIN
             DELETE FROM Revista WHERE RevistaID = @RevistaID 
         END
      ELSE IF (@RevistaID IS NULL)
         BEGIN
             INSERT INTO Revista (RevistaID, Titulo, Ano, Edicao, Capa, Publicador, Valor)
             VALUES (@RevistaID,@Titulo,@Ano,@Edicao,@Capa,@Publicador,@Valor)
         END
      ELSE
         BEGIN
             UPDATE Revista SET Titulo = @Titulo,
                                Ano = @Ano,
                                Edicao = @Edicao,
                                Capa = @Capa,
                                Publicador = @Publicador,
                                Valor = @Valor 
                     WHERE RevistaID = @RevistaID 
          END
          COMMIT TRAN
   END TRY
   BEGIN CATCH
      ROLLBACK TRAN
      SELECT ERROR_MESSAGE() AS Retorno
   END CATCH
   RETURN
END
GO

CREATE PROCEDURE uspConsultarRevista
@RevistaID AS CHAR(10) = NULL,
@Titulo AS VARCHAR(30) = NULL,
@Ano AS TINYINT = NULL,
@Edicao AS TINYINT = NULL,
@Capa AS VARCHAR(35) = NULL,
@Publicador AS VARCHAR(30) = NULL,
@Valor AS DECIMAL(12,2) = NULL
AS
BEGIN
SELECT RevistaID, Titulo, Ano, Edicao, Capa, Publicador, Valor
FROM Revista
WHERE ((RevistaID = @RevistaID) OR (@RevistaID IS NULL)) AND
      ((Titulo LIKE '%' + @Titulo + '%') OR (@Titulo IS NULL)) AND
      ((Ano = @Ano) OR ( @Ano IS NULL)) AND
      ((Edicao = @Edicao) OR (@Edicao IS NULL)) AND
      ((Capa = @Capa) OR (@Capa IS NULL)) AND
      ((Publicador = @Publicador) OR (@Publicador IS NULL)) AND
      ((Valor = @Valor) OR (@Valor IS NULL))
END
