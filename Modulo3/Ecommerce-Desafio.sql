create database ecommerce_desafio;
use ecommerce_desafio;

CREATE TABLE clients (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(15),
    Minit CHAR(3),
    Lname VARCHAR(20),
    Address VARCHAR(100),
    clientType ENUM('PF','PJ') NOT NULL
);


CREATE TABLE clientPF (
    idClientPF INT PRIMARY KEY,
    CPF CHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY (idClientPF) REFERENCES clients(idClient)
);

CREATE TABLE clientPJ (
    idClientPJ INT PRIMARY KEY,
    CNPJ CHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (idClientPJ) REFERENCES clients(idClient)
);

CREATE TABLE product (
    idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    classification_kids BOOL DEFAULT FALSE,
    category ENUM('Eletrônico','Vestimenta','Brinquedos','Alimentos','Móveis') NOT NULL,
    avaliacao FLOAT DEFAULT 0,
    size VARCHAR(20)
);

CREATE TABLE payments (
    idPayment INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    typePayment ENUM('Boleto','Cartão','Dois Cartões') NOT NULL,
    limitAvailable FLOAT,
    FOREIGN KEY (idClient) REFERENCES clients(idClient)
);

CREATE TABLE orders (
    idOrder INT AUTO_INCREMENT PRIMARY KEY,
    idOrderClient INT NOT NULL,
    orderStatus ENUM('Cancelado','Confirmado','Em processamento') DEFAULT 'Em processamento',
    orderDescription VARCHAR(255),
    sendValue FLOAT DEFAULT 10,
    paymentCash BOOL DEFAULT FALSE,
    FOREIGN KEY (idOrderClient) REFERENCES clients(idClient)
);

CREATE TABLE delivery (
    idDelivery INT AUTO_INCREMENT PRIMARY KEY,
    idOrder INT NOT NULL,
    trackingCode VARCHAR(50) NOT NULL,
    deliveryStatus ENUM('Postado','Em trânsito','Saiu para entrega','Entregue','Problema') DEFAULT 'Postado',
    FOREIGN KEY (idOrder) REFERENCES orders(idOrder)
);

CREATE TABLE productStorage (
    idProdStorage INT AUTO_INCREMENT PRIMARY KEY,
    storageLocation VARCHAR(255),
    quantity INT DEFAULT 0
);

CREATE TABLE supplier (
    idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ CHAR(14) NOT NULL UNIQUE,
    contact CHAR(11) NOT NULL
);

CREATE TABLE seller (
    idSeller INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    AbstName VARCHAR(255),
    CNPJ CHAR(14),
    CPF CHAR(11),
    location VARCHAR(255),
    contact CHAR(11) NOT NULL,
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ),
    CONSTRAINT unique_cpf_seller UNIQUE (CPF)
);

CREATE TABLE productSeller (
    idPseller INT,
    idPproduct INT,
    prodQuantity INT DEFAULT 1,
    PRIMARY KEY(idPseller, idPproduct),
    FOREIGN KEY (idPseller) REFERENCES seller(idSeller),
    FOREIGN KEY (idPproduct) REFERENCES product(idProduct)
);

CREATE TABLE productOrder (
    idPOproduct INT,
    idPOorder INT,
    poQuantity INT DEFAULT 1,
    poStatus ENUM('Disponível','Sem estoque') DEFAULT 'Disponível',
    PRIMARY KEY (idPOproduct, idPOorder),
    FOREIGN KEY (idPOproduct) REFERENCES product(idProduct),
    FOREIGN KEY (idPOorder) REFERENCES orders(idOrder)
);

CREATE TABLE storageLocation (
    idLproduct INT,
    idLstorage INT,
    location VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLproduct, idLstorage),
    FOREIGN KEY (idLproduct) REFERENCES product(idProduct),
    FOREIGN KEY (idLstorage) REFERENCES productStorage(idProdStorage)
);

CREATE TABLE productSupplier (
    idPsSupplier INT,
    idPsProduct INT,
    quantity INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
    FOREIGN KEY (idPsProduct) REFERENCES product(idProduct)
);

INSERT INTO clients (Fname, Minit, Lname, Address, clientType)
VALUES
('Maria','M','Silva','Rua A, 10','PF'),
('Empresa X',NULL,'LTDA','Av Central, 200','PJ');

INSERT INTO clientPF VALUES (1, '12345678901');
INSERT INTO clientPJ VALUES (2, '12345678000199');

INSERT INTO product (Pname, classification_kids, category, avaliacao, size) VALUES
('Fone de ouvido', FALSE, 'Eletrônico', 4, NULL),
('Barbie Elsa', TRUE, 'Brinquedos', 3, NULL),
('Body Carters', TRUE, 'Vestimenta', 5, NULL),
('Microfone Vedo', FALSE, 'Eletrônico', 4, NULL),
('Sofá retrátil', FALSE, 'Móveis', 3, '3x57x80');

INSERT INTO payments (idClient, typePayment, limitAvailable) VALUES
(1, 'Cartão', 2000),
(1, 'Boleto', NULL),
(2, 'Cartão', 5000);

INSERT INTO orders (idOrderClient, orderDescription, sendValue, paymentCash)
VALUES
(1, 'Compra via app', 20, TRUE),
(2, 'Compra via site', 50, FALSE);

INSERT INTO delivery (idOrder, trackingCode, deliveryStatus)
VALUES
(1, 'BR123456789PT', 'Em trânsito'),
(2, 'BR987654321PT', 'Postado');

INSERT INTO supplier (SocialName, CNPJ, contact) VALUES
('Almeida e Filhos', '12345678000111', '21985474'),
('Eletrônicos Silva', '98765432000122', '21985484');

INSERT INTO productSupplier VALUES
(1,1,500),
(1,2,400),
(2,4,633);

INSERT INTO seller (SocialName, CNPJ, CPF, location, contact)
VALUES
('Tech Eletronics','12345678000111',NULL,'Rio de Janeiro','219946287'),
('Kids World','45678912000155',NULL,'São Paulo','1198657484');

INSERT INTO productSeller VALUES
(1,1,80),
(2,2,10);

INSERT INTO productStorage (storageLocation, quantity) VALUES
('Rio de Janeiro', 1000),
('São Paulo', 500);

INSERT INTO storageLocation VALUES
(1,1,'RJ'),
(2,2,'SP');