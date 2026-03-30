-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Cliente` (
  `idCliente` INT NOT NULL,
  `Nome` VARCHAR(45) NULL,
  `cpf` VARCHAR(45) NULL,
  `Contato` VARCHAR(45) NULL,
  PRIMARY KEY (`idCliente`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Ordem de Serviço`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Ordem de Serviço` (
  `idOrdem de Serviço` INT NOT NULL,
  `Status da OS` VARCHAR(45) NULL,
  PRIMARY KEY (`idOrdem de Serviço`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Pedido` (
  `idPedido` INT NOT NULL,
  `Serviço` VARCHAR(45) NULL,
  `Descrição` VARCHAR(45) NULL,
  `Data da Solicitação` DATE NULL,
  `Cliente_idCliente` INT NOT NULL,
  `Liberado` TINYINT NULL,
  `Ordem de Serviço_idOrdem de Serviço` INT NOT NULL,
  PRIMARY KEY (`idPedido`, `Cliente_idCliente`, `Ordem de Serviço_idOrdem de Serviço`),
  INDEX `fk_Pedido_Cliente_idx` (`Cliente_idCliente` ASC) VISIBLE,
  INDEX `fk_Pedido_Ordem de Serviço1_idx` (`Ordem de Serviço_idOrdem de Serviço` ASC) VISIBLE,
  CONSTRAINT `fk_Pedido_Cliente`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `mydb`.`Cliente` (`idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pedido_Ordem de Serviço1`
    FOREIGN KEY (`Ordem de Serviço_idOrdem de Serviço`)
    REFERENCES `mydb`.`Ordem de Serviço` (`idOrdem de Serviço`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Responsável`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Responsável` (
  `idResponsável` INT NOT NULL,
  `Nível helpdesk` VARCHAR(45) NULL,
  `Nome` VARCHAR(45) NULL,
  `Departamento` VARCHAR(45) NULL,
  PRIMARY KEY (`idResponsável`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Análise de Pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Análise de Pedido` (
  `Pedido_idPedido` INT NOT NULL,
  `Pedido_Cliente_idCliente` INT NOT NULL,
  `Responsável_idResponsável` INT NOT NULL,
  PRIMARY KEY (`Pedido_idPedido`, `Pedido_Cliente_idCliente`, `Responsável_idResponsável`),
  INDEX `fk_Pedido_has_Responsável_Responsável1_idx` (`Responsável_idResponsável` ASC) VISIBLE,
  INDEX `fk_Pedido_has_Responsável_Pedido1_idx` (`Pedido_idPedido` ASC, `Pedido_Cliente_idCliente` ASC) VISIBLE,
  CONSTRAINT `fk_Pedido_has_Responsável_Pedido1`
    FOREIGN KEY (`Pedido_idPedido` , `Pedido_Cliente_idCliente`)
    REFERENCES `mydb`.`Pedido` (`idPedido` , `Cliente_idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pedido_has_Responsável_Responsável1`
    FOREIGN KEY (`Responsável_idResponsável`)
    REFERENCES `mydb`.`Responsável` (`idResponsável`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
