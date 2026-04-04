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

-- SELECTS

-- Clientes PJ com pedidos ativos
SELECT Nome, Endereço 
FROM `mydb`.`Cliente PJ` 
WHERE idCliente IN (SELECT DISTINCT Cliente PJ id FROM `mydb`.`Pedido`);

-- Produtos ordenados por valor (convertendo para decimal)
SELECT Nome, Categoria, CAST(Valor AS DECIMAL(10,2)) as Preco
FROM `mydb`.`Produto`
ORDER BY Preco DESC;

-- Produtos que aparecem em mais de 1 pedido
SELECT p.Nome, COUNT(pcp.Produto_idProduto) as TotalVendas
FROM `mydb`.`Produto` p
JOIN `mydb`.`Pedido contém Produtos` pcp ON p.idProduto = pcp.Produto_idProduto
GROUP BY p.idProduto, p.Nome
HAVING TotalVendas > 1;

-- Produtos, seus fornecedores e quantidade em estoque
SELECT p.Nome as Produto, f.`Razão Social` as Fornecedor, e.Quantidade as Estoque
FROM `mydb`.`Produto` p
JOIN `mydb`.`Produto Disponível` pd ON p.idProduto = pd.Produto_idProduto
JOIN `mydb`.`Fornecedor` f ON pd.Fornecedor_idFornecedor = f.idFornecedor
JOIN `mydb`.`Estoque_has_Produto` ep ON p.idProduto = ep.Produto_idProduto
JOIN `mydb`.`Estoque` e ON ep.Estoque_idEstoque = e.idEstoque;

-- Valor total dos pedidos com frete
SELECT 
    pe.idPedido,
    pe.`Status`,
    CAST(pe.Frete AS DECIMAL(10,2)) as Frete,
    CAST(SUM(CAST(p.Valor AS DECIMAL(10,2))) as DECIMAL(10,2)) as TotalProdutos,
    CAST(SUM(CAST(p.Valor AS DECIMAL(10,2))) + CAST(pe.Frete AS DECIMAL(10,2)) as DECIMAL(10,2)) as ValorTotal
FROM `mydb`.`Pedido` pe
JOIN `mydb`.`Pedido contém Produtos` pcp ON pe.idPedido = pcp.Pedido_idPedido
JOIN `mydb`.`Produto` p ON pcp.Produto_idProduto = p.idProduto
WHERE pe.`Status` = 'Concluído'
GROUP BY pe.idPedido, pe.`Status`, pe.Frete;

-- Fornecedores com mais de 2 produtos fornecidos
SELECT 
    f.`Razão Social`, 
    f.CNPJ,
    COUNT(pd.Produto_idProduto) as QtdProdutos
FROM `mydb`.`Fornecedor` f
JOIN `mydb`.`Produto Disponível` pd ON f.idFornecedor = pd.Fornecedor_idFornecedor
GROUP BY f.idFornecedor, f.`Razão Social`, f.CNPJ
HAVING QtdProdutos > 2
ORDER BY QtdProdutos DESC;

-- Status dos pedidos com classificação
SELECT 
    p.idPedido,
    p.`Status`,
    e.`Status` as StatusEntrega,
    e.`Cógido de Rastreio`,
    CASE 
        WHEN p.`Status` = 'Concluído' AND e.`Status` = 'Entregue' THEN 'Pedido Finalizado'
        WHEN p.`Status` = 'Processando' THEN 'Em Andamento'
        WHEN p.`Status` = 'Cancelado' THEN 'Cancelado'
        ELSE 'Pendente'
    END as ClassificacaoPedido
FROM `mydb`.`Pedido` p
JOIN `mydb`.`Entrega` e ON p.`Entrega id` = e.idEntrega;

-- Pagamentos realizados em 2024
SELECT 
    idPagamento,
    `Data do Pagamento`,
    COALESCE(`Cartão de Crédito`, `Cartão de Débito`, PIX, Dinheiro) as FormaPagamento
FROM `mydb`.`Pagamento`
WHERE YEAR(`Data do Pagamento`) = 2024
ORDER BY `Data do Pagamento` DESC;

-- Clientes PF e seus pedidos com produtos
SELECT 
    cpf.Nome as Cliente,
    p.idPedido,
    p.`Status`,
    prod.Nome as Produto,
    CAST(prod.Valor AS DECIMAL(10,2)) as ValorProduto
FROM `mydb`.`Cliente PF` cpf
JOIN `mydb`.`Pedido` p ON cpf.`idCliente PF` = p.`Cliente PF id`
JOIN `mydb`.`Pedido contém Produtos` pcp ON p.idPedido = pcp.Pedido_idPedido
JOIN `mydb`.`Produto` prod ON pcp.Produto_idProduto = prod.idProduto
WHERE cpf.Nome IS NOT NULL;

-- Média de produtos por pedido
SELECT 
    p.idPedido,
    COUNT(pcp.Produto_idProduto) as QtdProdutos,
    AVG(CAST(prod.Valor AS DECIMAL(10,2))) as MediaValorProdutos
FROM `mydb`.`Pedido` p
JOIN `mydb`.`Pedido contém Produtos` pcp ON p.idPedido = pcp.Pedido_idPedido
JOIN `mydb`.`Produto` prod ON pcp.Produto_idProduto = prod.idProduto
GROUP BY p.idPedido
HAVING QtdProdutos > 1
ORDER BY MediaValorProdutos DESC;

-- Produtos e seus vendedores terceiros (completo)
SELECT 
    p.Nome as Produto,
    p.Categoria,
    COALESCE(tv.`Razão Social`, 'Sem vendedor terceiro') as VendedorTerceiro,
    COALESCE(pvt.Quantidade, '0') as QuantidadeVendida
FROM `mydb`.`Produto` p
LEFT JOIN `mydb`.`Produtos Vendido por Terceiros` pvt ON p.idProduto = pvt.Produto_idProduto
LEFT JOIN `mydb`.`Terceiro Vendedor` tv ON pvt.`Terceiro Vendedor_idTerceiro Vendedor` = tv.`idTerceiro Vendedor`
ORDER BY p.Categoria, p.Nome;

