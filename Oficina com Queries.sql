CREATE TABLE IF NOT EXISTS `mydb`.`Manutenção` (
  `idManutenção` INT NOT NULL,
  PRIMARY KEY (`idManutenção`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Revisão` (
  `idRevisão` INT NOT NULL,
  PRIMARY KEY (`idRevisão`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Cliente` (
  `idCliente` INT NOT NULL,
  `Nome` VARCHAR(45) NOT NULL,
  `Endereço` VARCHAR(45) NOT NULL,
  `CPF` INT NOT NULL,
  PRIMARY KEY (`idCliente`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Equipe de Mecânicos` (
  `idEquipe de Mecânicos` INT NOT NULL,
  `Nome` VARCHAR(45) NOT NULL,
  `Especialidade` VARCHAR(45) NOT NULL,
  `Código` VARCHAR(45) NOT NULL,
  `Endereço` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idEquipe de Mecânicos`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Autorização OS` (
  `idAutorização OS` INT NOT NULL,
  `Data de Emissão` DATE NULL,
  `Tipo de Serviço` VARCHAR(45) NULL,
  `Autorização OScol` VARCHAR(45) NOT NULL,
  `Valor` VARCHAR(45) NOT NULL,
  `Equipe de Mecânicos ID` INT NOT NULL,
  `Cliente ID` INT NOT NULL,
  PRIMARY KEY (`idAutorização OS`, `Equipe de Mecânicos ID`, `Cliente ID`),
  INDEX `fk_Autorização OS_Cliente1_idx` (`Cliente ID` ASC) VISIBLE,
  INDEX `fk_Autorização OS_Equipe de Mecânicos1_idx` (`Equipe de Mecânicos ID` ASC) VISIBLE,
  CONSTRAINT `fk_Autorização OS_Cliente1`
    FOREIGN KEY (`Cliente ID`)
    REFERENCES `mydb`.`Cliente` (`idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Autorização OS_Equipe de Mecânicos1`
    FOREIGN KEY (`Equipe de Mecânicos ID`)
    REFERENCES `mydb`.`Equipe de Mecânicos` (`idEquipe de Mecânicos`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Ordem de Serviço` (
  `idOrdem de Serviço` INT NOT NULL,
  `Data de Entrega` DATE NOT NULL,
  `Valor do Serviço` VARCHAR(45) NOT NULL,
  `Valor das peças` VARCHAR(45) NOT NULL,
  `Data de Emissão` DATE NOT NULL,
  `Status` VARCHAR(45) NOT NULL,
  `Equipe de Mecânicos ID` INT NOT NULL,
  `Autorização OS ID` INT NOT NULL,
  PRIMARY KEY (`idOrdem de Serviço`, `Equipe de Mecânicos ID`, `Autorização OS ID`),
  INDEX `fk_Ordem de Serviço_Autorização OS1_idx` (`Autorização OS ID` ASC) VISIBLE,
  INDEX `fk_Ordem de Serviço_Equipe de Mecânicos1_idx` (`Equipe de Mecânicos ID` ASC) VISIBLE,
  CONSTRAINT `fk_Ordem de Serviço_Autorização OS1`
    FOREIGN KEY (`Autorização OS ID`)
    REFERENCES `mydb`.`Autorização OS` (`idAutorização OS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Ordem de Serviço_Equipe de Mecânicos1`
    FOREIGN KEY (`Equipe de Mecânicos ID`)
    REFERENCES `mydb`.`Equipe de Mecânicos` (`idEquipe de Mecânicos`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Carro` (
  `idCarro` INT NOT NULL,
  `Placa` VARCHAR(45) NOT NULL,
  `Marca` VARCHAR(45) NOT NULL,
  `Ano` VARCHAR(45) NOT NULL,
  `Cliente ID` INT NOT NULL,
  `Mecânicos ID` INT NOT NULL,
  PRIMARY KEY (`idCarro`, `Cliente ID`, `Mecânicos ID`),
  INDEX `fk_Carro_Cliente1_idx` (`Cliente ID` ASC) VISIBLE,
  INDEX `fk_Carro_Equipe de Mecânicos1_idx` (`Mecânicos ID` ASC) VISIBLE,
  CONSTRAINT `fk_Carro_Cliente1`
    FOREIGN KEY (`Cliente ID`)
    REFERENCES `mydb`.`Cliente` (`idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Carro_Equipe de Mecânicos1`
    FOREIGN KEY (`Mecânicos ID`)
    REFERENCES `mydb`.`Equipe de Mecânicos` (`idEquipe de Mecânicos`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Equipe de Mecânicos Executa Revisão` (
  `Equipe de Mecânicos ID` INT NOT NULL,
  `Revisão ID` INT NOT NULL,
  PRIMARY KEY (`Equipe de Mecânicos ID`, `Revisão ID`),
  INDEX `fk_Equipe de Mecânicos_has_Revisão_Revisão1_idx` (`Revisão ID` ASC) VISIBLE,
  INDEX `fk_Equipe de Mecânicos_has_Revisão_Equipe de Mecânicos1_idx` (`Equipe de Mecânicos ID` ASC) VISIBLE,
  CONSTRAINT `fk_Equipe de Mecânicos_has_Revisão_Equipe de Mecânicos1`
    FOREIGN KEY (`Equipe de Mecânicos ID`)
    REFERENCES `mydb`.`Equipe de Mecânicos` (`idEquipe de Mecânicos`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipe de Mecânicos_has_Revisão_Revisão1`
    FOREIGN KEY (`Revisão ID`)
    REFERENCES `mydb`.`Revisão` (`idRevisão`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Equipe de Mecânicos Executa Manutenção` (
  `Equipe de Mecânicos ID` INT NOT NULL,
  `Manutenção ID` INT NOT NULL,
  PRIMARY KEY (`Equipe de Mecânicos ID`, `Manutenção ID`),
  INDEX `fk_Equipe de Mecânicos_has_Manutenção_Manutenção1_idx` (`Manutenção ID` ASC) VISIBLE,
  INDEX `fk_Equipe de Mecânicos_has_Manutenção_Equipe de Mecânic_idx` (`Equipe de Mecânicos ID` ASC) VISIBLE,
  CONSTRAINT `fk_Equipe de Mecânicos_has_Manutenção_Equipe de Mecânicos1`
    FOREIGN KEY (`Equipe de Mecânicos ID`)
    REFERENCES `mydb`.`Equipe de Mecânicos` (`idEquipe de Mecânicos`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Equipe de Mecânicos_has_Manutenção_Manutenção1`
    FOREIGN KEY (`Manutenção ID`)
    REFERENCES `mydb`.`Manutenção` (`idManutenção`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

INSERT INTO `mydb`.`Manutenção` (`idManutenção`) VALUES
(1),
(2),
(3),
(4),
(5);

INSERT INTO `mydb`.`Revisão` (`idRevisão`) VALUES
(101),
(102),
(103),
(104),
(105);

INSERT INTO `mydb`.`Cliente` (`idCliente`, `Nome`, `Endereço`, `CPF`) VALUES
(1, 'João Silva', 'Rua A, 123 - São Paulo, SP', 12345678901),
(2, 'Maria Santos', 'Av. B, 456 - Rio de Janeiro, RJ', 23456789012),
(3, 'Pedro Oliveira', 'Rua C, 789 - Belo Horizonte, MG', 34567890123),
(4, 'Ana Costa', 'Av. D, 101 - Porto Alegre, RS', 45678901234),
(5, 'Carlos Lima', 'Rua E, 202 - Curitiba, PR', 56789012345);

INSERT INTO `mydb`.`Equipe de Mecânicos` (`idEquipe de Mecânicos`, `Nome`, `Especialidade`, `Código`, `Endereço`) VALUES
(1, 'Equipe Turbo', 'Motor e Injeção Eletrônica', 'EQT001', 'Oficina Central, Rua dos Mecânicos, 100'),
(2, 'Equipe Freios & Suspensão', 'Sistemas de Freios e Suspensão', 'EQF002', 'Oficina Sul, Av. das Oficinas, 200'),
(3, 'Equipe Elétrica', 'Sistemas Elétricos e Ar Condicionado', 'EQE003', 'Oficina Norte, Rua Elétrica, 300'),
(4, 'Equipe Transmissão', 'Câmbio e Transmissão', 'EQT004', 'Oficina Leste, Av. Transmissão, 400'),
(5, 'Equipe Funilaria', 'Funilaria e Pintura', 'EQF005', 'Oficina Oeste, Rua Pintura, 500');

INSERT INTO `mydb`.`Autorização OS` (`idAutorização OS`, `Data de Emissão`, `Tipo de Serviço`, `Autorização OScol`, `Valor`, `Equipe de Mecânicos ID`, `Cliente ID`) VALUES
(1001, '2024-01-15', 'Revisão completa', 'AUT001', '500.00', 1, 1),
(1002, '2024-01-20', 'Troca de óleo', 'AUT002', '150.00', 2, 2),
(1003, '2024-02-10', 'Alinhamento e balanceamento', 'AUT003', '200.00', 2, 3),
(1004, '2024-02-25', 'Reparo no motor', 'AUT004', '2500.00', 1, 4),
(1005, '2024-03-05', 'Troca de pastilhas de freio', 'AUT005', '350.00', 2, 5);

INSERT INTO `mydb`.`Ordem de Serviço` (`idOrdem de Serviço`, `Data de Entrega`, `Valor do Serviço`, `Valor das peças`, `Data de Emissão`, `Status`, `Equipe de Mecânicos ID`, `Autorização OS ID`) VALUES
(5001, '2024-01-20', '400.00', '100.00', '2024-01-15', 'Concluído', 1, 1001),
(5002, '2024-01-25', '120.00', '30.00', '2024-01-20', 'Concluído', 2, 1002),
(5003, '2024-02-15', '180.00', '20.00', '2024-02-10', 'Em andamento', 2, 1003),
(5004, '2024-03-10', '2000.00', '500.00', '2024-02-25', 'Em andamento', 1, 1004),
(5005, '2024-03-10', '250.00', '100.00', '2024-03-05', 'Aguardando peças', 2, 1005);

INSERT INTO `mydb`.`Carro` (`idCarro`, `Placa`, `Marca`, `Ano`, `Cliente ID`, `Mecânicos ID`) VALUES
(1, 'ABC-1234', 'Fiat', '2020', 1, 1),
(2, 'DEF-5678', 'Volkswagen', '2019', 2, 2),
(3, 'GHI-9012', 'Chevrolet', '2021', 3, 2),
(4, 'JKL-3456', 'Ford', '2018', 4, 1),
(5, 'MNO-7890', 'Hyundai', '2022', 5, 3),
(6, 'PQR-1234', 'Toyota', '2020', 1, 2),
(7, 'STU-5678', 'Honda', '2019', 2, 1);

INSERT INTO `mydb`.`Equipe de Mecânicos Executa Revisão` (`Equipe de Mecânicos ID`, `Revisão ID`) VALUES
(1, 101),
(2, 102),
(3, 103),
(1, 104),
(2, 105),
(4, 101),
(5, 102);

INSERT INTO `mydb`.`Equipe de Mecânicos Executa Manutenção` (`Equipe de Mecânicos ID`, `Manutenção ID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 4),
(2, 5),
(4, 1),
(5, 2),
(3, 4);

-- Verificar contagem de registros
SELECT 'Manutenção' as Tabela, COUNT(*) as Registros FROM `mydb`.`Manutenção`
UNION ALL
SELECT 'Revisão', COUNT(*) FROM `mydb`.`Revisão`
UNION ALL
SELECT 'Cliente', COUNT(*) FROM `mydb`.`Cliente`
UNION ALL
SELECT 'Equipe de Mecânicos', COUNT(*) FROM `mydb`.`Equipe de Mecânicos`
UNION ALL
SELECT 'Autorização OS', COUNT(*) FROM `mydb`.`Autorização OS`
UNION ALL
SELECT 'Ordem de Serviço', COUNT(*) FROM `mydb`.`Ordem de Serviço`
UNION ALL
SELECT 'Carro', COUNT(*) FROM `mydb`.`Carro`
UNION ALL
SELECT 'Equipe de Mecânicos Executa Revisão', COUNT(*) FROM `mydb`.`Equipe de Mecânicos Executa Revisão`
UNION ALL
SELECT 'Equipe de Mecânicos Executa Manutenção', COUNT(*) FROM `mydb`.`Equipe de Mecânicos Executa Manutenção`;

-- Carros ordenados por ano
SELECT Placa, Marca, Ano
FROM `mydb`.`Carro`
ORDER BY Ano DESC;

-- Calculando valor total do serviço + peças
SELECT 
    `idOrdem de Serviço`,
    `Valor do Serviço`,
    `Valor das peças`,
    CAST(`Valor do Serviço` AS DECIMAL(10,2)) + CAST(`Valor das peças` AS DECIMAL(10,2)) as Valor_Total
FROM `mydb`.`Ordem de Serviço`;

-- Simples: Clientes com seus carros
SELECT 
    c.Nome as Cliente,
    car.Placa,
    car.Marca
FROM `mydb`.`Cliente` c
JOIN `mydb`.`Carro` car ON c.idCliente = car.`Cliente ID`;


-- OS concluídas ordenadas por data
SELECT 
    `idOrdem de Serviço`,
    `Data de Entrega`,
    `Status`
FROM `mydb`.`Ordem de Serviço`
WHERE `Status` = 'Concluído'
ORDER BY `Data de Entrega` DESC;

-- Ordens de serviço de revisão
SELECT 
    os.`idOrdem de Serviço`,
    aos.`Tipo de Serviço`,
    os.`Status`
FROM `mydb`.`Ordem de Serviço` os
JOIN `mydb`.`Autorização OS` aos ON os.`Autorização OS ID` = aos.`idAutorização OS`
WHERE aos.`Tipo de Serviço` = 'Revisão completa';

-- Quantidade de carros por cliente
SELECT 
    c.Nome,
    COUNT(car.idCarro) as Quantidade_Carros
FROM `mydb`.`Cliente` c
LEFT JOIN `mydb`.`Carro` car ON c.idCliente = car.`Cliente ID`
GROUP BY c.idCliente, c.Nome;




