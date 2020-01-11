-- CRIANDO UM NOVO DATABASE --
CREATE DATABASE databasename;

-- EXEMPLO PADRÃO --
CREATE TABLE table_name (
    name VARCHAR(20),
    owner VARCHAR(20),
    sex CHAR(1),
    birth DATE,
    age INTEGER
);

-- CRIANDO A TABLE PERSONS COM ID NA CHAVE PRIMÁRIA--
CREATE TABLE Persons (
    ID int NOT NULL, -- Este será o campo da chave primária 
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int,
    PRIMARY KEY (ID)
);

CREATE TABLE Persons (
    ID int NOT NULL AUTO_INCREMENT, -- Campo com auto incremento
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int,
    PRIMARY KEY (ID)
);

-- CRIANDO A TABELA ORDERS --
CREATE TABLE Orders (
    ID int NOT NULL AUTO_INCREMENT,
    OrderNumber int NOT NULL,
    PersonID int,
    PRIMARY KEY (ID),
    FOREIGN KEY (PersonID) REFERENCES Persons(ID)
);

-- INSERINDO DADOS NA TABELA PERSONS --
INSERT INTO Persons
    ( LastName, FirstName, Age )
VALUES
    ( 'Gado', 'Davi', 15 );

-- INSERINDO DADOS NA TABELA ORDERS --
INSERT INTO Orders
    ( OrderNumber, PersonID )
VALUES
    ( 545, 1 );

-- VISUALIZANDO TODOS OS DADOS DA TABELA PERSONS --
SELECT * FROM Persons;

-- VISUALIZANDO APENAS O LastName DA TABELA PERSONS --
SELECT LastName FROM Persons;

----------- INSERIR DADOS CSV -----------

-- VISUALIZANDO TODOS AS PESSOAS COM IDADE MAIOR QUE 30 ANOS --
SELECT * FROM Persons WHERE Age > 30;
-- UTILIZANDO O LIKE--
SELECT * FROM Persons LIKE p WHERE p.Age > 30;
-- UTILIZANDO O ALIAS--
SELECT * FROM Persons p WHERE p.Age > 30;

-- VISUALIZANDO A COMBINAÇÃO DE PESSOAS COM SEUS PEDIDOS --
SELECT 
    * 
FROM    
    Persons p INNER JOIN Orders o
ON
    p.ID = o.ID;

-- VISUALIZANDO A COMBINAÇÃO DE PESSOAS COM SEUS PEDIDOS QUE POSSUEM IDADE MAIOR QUE 30 ANOS --
SELECT
    p.FirstName,
    P.Age,
    o.OrderNumber
FROM
    Persons p INNER JOIN Orders o
ON 
    p.ID = o.PersonID
WHERE
    p.Age > 30;

-- VISUALIZANDO A COMBINAÇÃO DE PESSOAS COM SEUS PEDIDOS QUE POSSUEM IDADE MENOR QUE 30 ANOS E QUE POSSUEM O SEGUNDO NOME 'Gado' --
SELECT
    p.FirstName,
    P.Age,
    o.OrderNumber
FROM
    Persons p INNER JOIN Orders o
ON 
    p.ID = o.PersonID
WHERE
    p.Age > 30 AND p.LastName = 'Gado';

-- ADICIONANDO O CAMPO Email NA TABELA PERSONS --
ALTER TABLE Persons ADD Email varchar(255);

-- ALTERANDO O VALOR DA TABELA PERSONS --
UPDATE Persons p
SET 
    p.Email = 'davigado@cuck.com'
WHERE
    p.ID = 1;

-- SELECIONANDO TODAS AS PESSOAS POR ORDEM ALFABETICA --
SELECT 
    * 
FROM 
    Persons 
ORDER BY 
    FirstName;

-- SELECIONANDO A QUANTIDADE DE ROWS DA TABELA PERSONS --
SELECT 
    COUNT(*) 
FROM 
    Persons 
GROUP BY 
    FirstName;   

-- SELECIONANDO A QUANTIDADE DE PESSOAS DA TABELA PERSONS QUE POSSUEM MAIS DE 30 ANOS --
SELECT 
    COUNT(*) 
FROM 
    Persons p 
WHERE 
    p.Age > 30 
GROUP BY 
    FirstName;

-- SELECIONANDO A MEDIA DAS IDADES DAS PESSOAS --
SELECT 
    AVG(Age) 
FROM 
    Persons 
GROUP BY 
Age;

-- SELECIONANDO A SOMA DAS IDADES DE TODAS AS PESSOAS --
SELECT 
    SUM(Age) 
FROM 
    Persons 
GROUP BY 
    Age;