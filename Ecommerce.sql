 CREATE TABLE IF NOT EXISTS `mydb`.`Cliente PJ` (
  `idCliente` INT NOT NULL,
  `Nome` VARCHAR(45) NOT NULL,
  `Endereço` VARCHAR(45) NOT NULL,
  `Pedido_idPedido` INT NOT NULL,
  PRIMARY KEY (`idCliente`, `Pedido_idPedido`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Entrega` (
  `idEntrega` INT NOT NULL,
  `Status` VARCHAR(45) NOT NULL,
  `Cógido de Rastreio` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idEntrega`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Cliente PF` (
  `idCliente PF` INT NOT NULL,
  `Nome` VARCHAR(45) NULL,
  `Endereço` VARCHAR(45) NULL,
  PRIMARY KEY (`idCliente PF`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Pedido` (
  `idPedido` INT NOT NULL,
  `Status` VARCHAR(45) NOT NULL,
  `Descrição` VARCHAR(45) NULL,
  `Cliente PJ id` INT NOT NULL,
  `Frete` VARCHAR(45) NULL,
  `Entrega id` INT NOT NULL,
  `Cliente PF id` INT NOT NULL,
  PRIMARY KEY (`idPedido`, `Cliente PJ id`, `Entrega id`, `Cliente PF id`),
  INDEX `fk_Pedido_Cliente1_idx` (`Cliente PJ id` ASC) VISIBLE,
  INDEX `fk_Pedido_Entrega1_idx` (`Entrega id` ASC) VISIBLE,
  INDEX `fk_Pedido_Cliente PF1_idx` (`Cliente PF id` ASC) VISIBLE,
  CONSTRAINT `fk_Pedido_Cliente1`
    FOREIGN KEY (`Cliente PJ id`)
    REFERENCES `mydb`.`Cliente PJ` (`idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pedido_Entrega1`
    FOREIGN KEY (`Entrega id`)
    REFERENCES `mydb`.`Entrega` (`idEntrega`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pedido_Cliente PF1`
    FOREIGN KEY (`Cliente PF id`)
    REFERENCES `mydb`.`Cliente PF` (`idCliente PF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Produto` (
  `idProduto` INT NOT NULL,
  `Nome` VARCHAR(45) NOT NULL,
  `Categoria` VARCHAR(45) NULL,
  `Valor` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idProduto`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Estoque` (
  `idEstoque` INT NOT NULL,
  `Quantidade` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idEstoque`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Fornecedor` (
  `idFornecedor` INT NOT NULL,
  `CNPJ` VARCHAR(45) NOT NULL,
  `Razão Social` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idFornecedor`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Pedido contém Produtos` (
  `Produto_idProduto` INT NOT NULL,
  `Pedido_idPedido` INT NOT NULL,
  PRIMARY KEY (`Produto_idProduto`, `Pedido_idPedido`),
  INDEX `fk_Produto_has_Pedido_Pedido1_idx` (`Pedido_idPedido` ASC) VISIBLE,
  INDEX `fk_Produto_has_Pedido_Produto1_idx` (`Produto_idProduto` ASC) VISIBLE,
  CONSTRAINT `fk_Produto_has_Pedido_Produto1`
    FOREIGN KEY (`Produto_idProduto`)
    REFERENCES `mydb`.`Produto` (`idProduto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Produto_has_Pedido_Pedido1`
    FOREIGN KEY (`Pedido_idPedido`)
    REFERENCES `mydb`.`Pedido` (`idPedido`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Produto Disponível` (
  `Produto_idProduto` INT NOT NULL,
  `Fornecedor_idFornecedor` INT NOT NULL,
  PRIMARY KEY (`Produto_idProduto`, `Fornecedor_idFornecedor`),
  INDEX `fk_Produto_has_Fornecedor_Fornecedor1_idx` (`Fornecedor_idFornecedor` ASC) VISIBLE,
  INDEX `fk_Produto_has_Fornecedor_Produto1_idx` (`Produto_idProduto` ASC) VISIBLE,
  CONSTRAINT `fk_Produto_has_Fornecedor_Produto1`
    FOREIGN KEY (`Produto_idProduto`)
    REFERENCES `mydb`.`Produto` (`idProduto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Produto_has_Fornecedor_Fornecedor1`
    FOREIGN KEY (`Fornecedor_idFornecedor`)
    REFERENCES `mydb`.`Fornecedor` (`idFornecedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Estoque_has_Produto` (
  `Estoque_idEstoque` INT NOT NULL,
  `Produto_idProduto` INT NOT NULL,
  PRIMARY KEY (`Estoque_idEstoque`, `Produto_idProduto`),
  INDEX `fk_Estoque_has_Produto_Produto1_idx` (`Produto_idProduto` ASC) VISIBLE,
  INDEX `fk_Estoque_has_Produto_Estoque1_idx` (`Estoque_idEstoque` ASC) VISIBLE,
  CONSTRAINT `fk_Estoque_has_Produto_Estoque1`
    FOREIGN KEY (`Estoque_idEstoque`)
    REFERENCES `mydb`.`Estoque` (`idEstoque`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Estoque_has_Produto_Produto1`
    FOREIGN KEY (`Produto_idProduto`)
    REFERENCES `mydb`.`Produto` (`idProduto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Terceiro Vendedor` (
  `idTerceiro Vendedor` INT NOT NULL,
  `Razão Social` VARCHAR(45) NULL,
  `Local` VARCHAR(45) NULL,
  PRIMARY KEY (`idTerceiro Vendedor`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Produtos Vendido por Terceiros` (
  `Terceiro Vendedor_idTerceiro Vendedor` INT NOT NULL,
  `Produto_idProduto` INT NOT NULL,
  `Quantidade` VARCHAR(45) NULL,
  PRIMARY KEY (`Terceiro Vendedor_idTerceiro Vendedor`, `Produto_idProduto`),
  INDEX `fk_Terceiro Vendedor_has_Produto_Produto1_idx` (`Produto_idProduto` ASC) VISIBLE,
  INDEX `fk_Terceiro Vendedor_has_Produto_Terceiro Vendedor1_idx` (`Terceiro Vendedor_idTerceiro Vendedor` ASC) VISIBLE,
  CONSTRAINT `fk_Terceiro Vendedor_has_Produto_Terceiro Vendedor1`
    FOREIGN KEY (`Terceiro Vendedor_idTerceiro Vendedor`)
    REFERENCES `mydb`.`Terceiro Vendedor` (`idTerceiro Vendedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Terceiro Vendedor_has_Produto_Produto1`
    FOREIGN KEY (`Produto_idProduto`)
    REFERENCES `mydb`.`Produto` (`idProduto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Pagamento` (
  `idPagamento` INT NOT NULL,
  `Cartão de Crédito` VARCHAR(45) NULL,
  `Cartão de Débito` VARCHAR(45) NULL,
  `PIX` VARCHAR(45) NULL,
  `Dinheiro` VARCHAR(45) NULL,
  `Pedido id` INT NOT NULL,
  `Cliente PJ id` INT NOT NULL,
  `Cliente PF id` INT NOT NULL,
  `Data do Pagamento` DATE NULL,
  PRIMARY KEY (`idPagamento`, `Pedido id`, `Cliente PJ id`, `Cliente PF id`),
  INDEX `fk_Pagamento_Pedido1_idx` (`Pedido id` ASC) VISIBLE,
  INDEX `fk_Pagamento_Cliente1_idx` (`Cliente PJ id` ASC) VISIBLE,
  INDEX `fk_Pagamento_Cliente PF1_idx` (`Cliente PF id` ASC) VISIBLE,
  CONSTRAINT `fk_Pagamento_Pedido1`
    FOREIGN KEY (`Pedido id`)
    REFERENCES `mydb`.`Pedido` (`idPedido`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pagamento_Cliente1`
    FOREIGN KEY (`Cliente PJ id`)
    REFERENCES `mydb`.`Cliente PJ` (`idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Pagamento_Cliente PF1`
    FOREIGN KEY (`Cliente PF id`)
    REFERENCES `mydb`.`Cliente PF` (`idCliente PF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

