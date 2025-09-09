DROP DATABASE IF EXISTS Assinaturas;
CREATE DATABASE Assinaturas;
USE Assinaturas;

CREATE TABLE Municipio (
    cd_municipio INT PRIMARY KEY AUTO_INCREMENT,
    ds_municipio VARCHAR(100) NOT NULL
);

CREATE TABLE Endereco (
    cd_endereco INT PRIMARY KEY AUTO_INCREMENT,
    ds_endereco VARCHAR(150) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cep VARCHAR(10),
    cd_municipio INT NOT NULL,
    FOREIGN KEY (cd_municipio) REFERENCES Municipio(cd_municipio)
);

CREATE TABLE Telefone (
    cd_fone INT PRIMARY KEY AUTO_INCREMENT,
    ddd CHAR(3) NOT NULL,
    n_fone VARCHAR(15) NOT NULL,
    cd_endereco INT NOT NULL,
    FOREIGN KEY (cd_endereco) REFERENCES Endereco(cd_endereco)
);

CREATE TABLE Ramo_Atividade (
    cd_ramo INT PRIMARY KEY AUTO_INCREMENT,
    ds_ramo VARCHAR(100) NOT NULL
);

CREATE TABLE Tipo_Assinante (
    cd_tipo INT PRIMARY KEY AUTO_INCREMENT,
    ds_tipo VARCHAR(100) NOT NULL
);

CREATE TABLE Assinante (
    cd_assinante INT PRIMARY KEY AUTO_INCREMENT,
    nm_assinante VARCHAR(150) NOT NULL,
    cd_endereco INT NOT NULL,
    cd_ramo INT,
    cd_tipo INT,
    FOREIGN KEY (cd_endereco) REFERENCES Endereco(cd_endereco),
    FOREIGN KEY (cd_ramo) REFERENCES Ramo_Atividade(cd_ramo),
    FOREIGN KEY (cd_tipo) REFERENCES Tipo_Assinante(cd_tipo)
);

-- Inserts gerados pelo chatgpt

INSERT INTO Municipio (ds_municipio) VALUES
('Pelotas'),
('Natal'),
('João Câmara'),
('Porto Alegre');

INSERT INTO Endereco (ds_endereco, complemento, bairro, cep, cd_municipio) VALUES
('Rua das Flores, 123', 'Apto 101', 'Centro', '96000-000', 1),
('Av. Brasil, 500', NULL, 'Ponta Negra', '59000-000', 2),
('Rua Principal, 45', 'Casa', 'Centro', '59550-000', 3),
('Av. Ipiranga, 2000', 'Bloco B', 'Partenon', '91530-000', 4);

INSERT INTO Telefone (ddd, n_fone, cd_endereco) VALUES
('53', '99999-1111', 1),
('53', '98888-2222', 1),
('84', '97777-3333', 2),
('84', '96666-4444', 3),
('51', '95555-5555', 4);

INSERT INTO Ramo_Atividade (ds_ramo) VALUES
('Tecnologia'),
('Saúde'),
('Educação'),
('Comércio');

INSERT INTO Tipo_Assinante (ds_tipo) VALUES
('Residencial'),
('Comercial');

INSERT INTO Assinante (nm_assinante, cd_endereco, cd_ramo, cd_tipo) VALUES
('Diogo Beltrame', 1, 1, 1),
('Rosangela Souza', 2, 4, 2),
('Felipe Campos', 3, 2, 2),
('João Silveira', 4, 3, 1);