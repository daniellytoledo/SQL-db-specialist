# SQL-db-specialist
Repository created for my projects from the SQL Database Specialist course from Dio platform.

---

PROJETOS

1. Ecommerce (Módulo 2 e 3):
   
  Este projeto consiste em um banco de dados relacional para um sistema de e-commerce, desenvolvido em MySQL, que gerencia todo o fluxo operacional de uma loja virtual. O modelo contempla desde o cadastro de clientes (Pessoa Física e Pessoa Jurídica) até o controle de pedidos, estoque, fornecedores, entregas e pagamentos.

🗂️ Estrutura do Banco de Dados
O banco de dados é composto pelas seguintes entidades principais:

🔹Clientes PF/PJ: Cadastro segregado por tipo de cliente

🔹Pedidos: Registro de transações com status e frete

🔹Produtos: Catálogo com nome, categoria e valor

🔹Estoque: Controle de quantidades disponíveis

🔹Fornecedores: Cadastro de empresas fornecedoras

🔹Terceiros Vendedores: Vendedores externos parceiros

🔹Entregas: Rastreamento e status de envio

🔹Pagamentos: Múltiplas formas de pagamento com data

🔍 Explicação das Cláusulas SQL Utilizadas

✅ WHERE: Filtra registros específicos com base em condições.
✅ ORDER BY: Ordena os resultados em ordem crescente (ASC) ou decrescente (DESC).
✅ GROUP BY: Agrupa registros com valores idênticos para funções de agregação.
✅ HAVING: Filtra grupos após a aplicação do GROUP BY (diferente do WHERE, que filtra antes).
✅ JOINs (INNER, LEFT, RIGHT): Combina registros de duas ou mais tabelas:

  INNER JOIN: Retorna apenas registros com correspondência
  LEFT JOIN: Retorna todos os registros da tabela esquerda

✅ Atributos Derivados: Campos calculados durante a consulta usando expressões.
✅ CASE (Estrutura Condicional): Cria categorizações ou classificações condicionais.
✅ Subconsultas: Consultas aninhadas dentro de outra consulta.

✅ Funções de Agregação: 

COUNT(): Conta registros
SUM(): Soma valores
AVG(): Calcula média
MAX()/MIN(): Valor máximo/mínimo


<img width="778" height="795" alt="e-commerce" src="https://github.com/user-attachments/assets/ce93ee00-0f7b-4a1a-8efe-5c47e6bd7bf3" />


2. Oficina mecânica (Módulo 2 - Modelo de Dados Relacionais):

<img width="782" height="675" alt="Oficina" src="https://github.com/user-attachments/assets/58b08f93-3f01-45aa-8839-99f946528fee" />

# 🗄️ Company Database — Índices e Queries de Recuperação de Informação

## Sobre o projeto

Este repositório contém a definição de **índices otimizados** e as **queries de recuperação de informação** para o banco de dados `company`, um schema clássico de RH com funcionários, departamentos, projetos e dependentes.

O objetivo é demonstrar como a criação consciente de índices impacta diretamente a **velocidade de busca no SGBD**, evitando varreduras completas de tabela (*full table scans*) nas consultas mais frequentes.

---

## Estrutura do banco

| Tabela | Descrição |
|---|---|
| `employee` | Funcionários, salário, supervisor e departamento |
| `departament` | Departamentos e seus gerentes |
| `dept_locations` | Localizações físicas de cada departamento |
| `project` | Projetos vinculados a departamentos |
| `works_on` | Horas trabalhadas por funcionário em cada projeto |
| `dependent` | Dependentes de cada funcionário |

---

## Critérios para criação de índices

Nem toda coluna merece um índice. Os seguintes critérios foram aplicados:

1. **Dados mais acessados** — colunas que aparecem em `JOIN`, `WHERE`, `GROUP BY` e `ORDER BY` nas queries de negócio.
2. **Relevância no contexto** — colunas que representam chaves estrangeiras sem índice automático (o motor **MyISAM** não cria índices em FKs automaticamente, ao contrário do InnoDB).
3. **Cardinalidade** — colunas com poucos valores distintos (ex: `Sex char(1)`) foram **intencionalmente excluídas**: o otimizador tende a ignorar esses índices e fazer full scan de qualquer forma.
4. **Tipo de índice** — foi utilizado **BTREE** (padrão no MySQL) em todas as colunas, pois suporta tanto buscas por igualdade quanto por intervalo e ordenação, o que cobre os padrões de acesso identificados.

---

## Índices criados

### `employee`

```sql
CREATE INDEX idx_employee_dno ON employee(Dno) USING BTREE;
```
**Motivo:** `Dno` é a chave estrangeira para o departamento e aparece em `JOIN` e `GROUP BY` nas três queries principais. Sem esse índice, cada consulta precisaria varrer todos os registros da tabela para encontrar os funcionários de um departamento.

```sql
CREATE INDEX idx_employee_super_ssn ON employee(super_ssn) USING BTREE;
```
**Motivo:** `super_ssn` é FK sem índice automático no MyISAM. Relevante para consultas hierárquicas (cadeia de supervisão) que são naturais neste contexto de RH.

---

### `dept_locations`

```sql
CREATE INDEX idx_dept_locations_dlocation ON dept_locations(Dlocation) USING BTREE;
```
**Motivo:** A coluna `Dlocation` (cidade) é usada em filtros e ordenação na Query 2. O índice BTREE permite ordenação alfabética eficiente e buscas por prefixo de cidade.

---

### Por que *não* foram criados índices adicionais?

| Tabela | Situação |
|---|---|
| `departament` | `Dnumber` é PK (índice automático). `Mgr_ssn` já declarado como `KEY` no schema. Nada a adicionar. |
| `dept_locations` | `(Dnumber, Dlocation)` é PK composta — o JOIN por `Dnumber` já é coberto. |
| `works_on` | PK composta `(Essn, Pno)` cobre os acessos típicos. `Pno` já possui `KEY` no schema. |
| `dependent` | PK composta `(Essn, Dependent_name)` é suficiente para as consultas de dependentes. |

---

## Queries

### 1. Departamento com maior número de pessoas

```sql
SELECT
    d.Dname        AS Departamento,
    COUNT(e.Ssn)   AS Total_Funcionarios
FROM
    employee e
    JOIN departament d ON e.Dno = d.Dnumber
GROUP BY
    d.Dnumber, d.Dname
ORDER BY
    Total_Funcionarios DESC
LIMIT 1;
```

**Índices utilizados:** `idx_employee_dno` — o MySQL usa o índice para agrupar os registros de `employee` por `Dno` sem precisar ordenar a tabela inteira.

**Resultado esperado com os dados de exemplo:**

| Departamento | Total_Funcionarios |
|---|---|
| Research | 3 |

---

### 2. Departamentos por cidade

```sql
SELECT
    dl.Dlocation   AS Cidade,
    d.Dname        AS Departamento
FROM
    dept_locations dl
    JOIN departament d ON dl.Dnumber = d.Dnumber
ORDER BY
    dl.Dlocation, d.Dname;
```

**Índices utilizados:** PK de `dept_locations` cobre o JOIN; `idx_dept_locations_dlocation` acelera o `ORDER BY Dlocation`.

**Resultado esperado:**

| Cidade | Departamento |
|---|---|
| Bellaire | Research |
| Houston | Headquarters |
| Houston | Research |
| Stafford | Administration |
| Sugarland | Research |

---

### 3. Relação de empregados por departamento

```sql
SELECT
    d.Dname                                         AS Departamento,
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname)   AS Funcionario,
    e.Salary                                         AS Salario
FROM
    employee e
    JOIN departament d ON e.Dno = d.Dnumber
ORDER BY
    d.Dname, e.Lname, e.Fname;
```

**Índices utilizados:** `idx_employee_dno` — o JOIN percorre o índice em vez de comparar linha a linha.

**Resultado esperado:**

| Departamento | Funcionario | Salario |
|---|---|---|
| Administration | Ahmad V. Jabbar | 26500.00 |
| Administration | Jennifer S. Wallace | 44500.00 |
| Administration | Alicia J. Zelaya | 26500.00 |
| Headquarters | James E. Borg | 56000.00 |
| Headquarters | John B. Smith | 32000.00 |
| Research | Joyce A. English | 27000.00 |
| Research | Ramesh K. Narayan | 40000.00 |
| Research | Franklin T. Wong | 42000.00 |

---

## EXPLAIN: se os índices estão sendo utilizados pelo otimizador

   ```sql
   EXPLAIN SELECT d.Dname, COUNT(e.Ssn) FROM employee e
   JOIN departament d ON e.Dno = d.Dnumber
   GROUP BY d.Dnumber ORDER BY 2 DESC LIMIT 1;
   ```
   A coluna `key` no resultado deve mostrar `idx_employee_dno`.

---

## Observação sobre o motor de armazenamento

O schema utiliza **MyISAM**. Diferentemente do InnoDB:
- MyISAM **não cria índices automaticamente para chaves estrangeiras** (a declaração `KEY` no DDL é apenas uma dica, não uma FK real com integridade referencial).
- MyISAM é mais rápido em leituras intensas mas não suporta transações nem bloqueio em nível de linha.

---

# 🔧 Company Database — Stored Procedure de Manutenção

## Sobre

Este módulo complementa o projeto de índices e queries do banco `company` com uma **stored procedure centralizada** (`sp_company_manutencao`) que encapsula todas as operações de escrita no banco: **INSERT**, **UPDATE** e **DELETE**.

A ideia central é ter **um único ponto de entrada** para modificações nos dados. A aplicação (ou o DBA) passa uma **variável de controle numérica** e a **entidade-alvo**, e a procedure decide internamente qual operação executar usando estruturas condicionais `IF` (para a entidade) e `CASE` (para a ação).

---

## Estrutura da procedure

```
sp_company_manutencao(
    p_acao      TINYINT,       ← variável de controle
    p_entidade  VARCHAR(20),   ← qual tabela operar
    ... parâmetros de dados ...,
    OUT p_mensagem VARCHAR(200) ← retorno para a aplicação
)
```

### Variável de controle — `p_acao`

| Valor | Operação |
|---|---|
| `1` | `INSERT` — insere novo registro |
| `2` | `UPDATE` — atualiza registro existente |
| `3` | `DELETE` — remove registro existente |

### Entidades suportadas — `p_entidade`

| Valor | Tabela |
|---|---|
| `'EMPLOYEE'` | `employee` |
| `'DEPARTMENT'` | `departament` |
| `'DEPENDENT'` | `dependent` |

---

## Fluxo de decisão

```
sp_company_manutencao()
│
├── IF p_entidade = 'EMPLOYEE'
│     └── CASE p_acao
│           ├── 1 → INSERT INTO employee ...
│           ├── 2 → UPDATE employee SET ... WHERE Ssn = p_emp_ssn
│           └── 3 → DELETE FROM employee WHERE Ssn = p_emp_ssn
│
├── ELSEIF p_entidade = 'DEPARTMENT'
│     └── CASE p_acao
│           ├── 1 → INSERT INTO departament ...
│           ├── 2 → UPDATE departament SET ... WHERE Dnumber = p_dept_dnumber
│           └── 3 → DELETE FROM departament WHERE Dnumber = p_dept_dnumber
│
├── ELSEIF p_entidade = 'DEPENDENT'
│     └── CASE p_acao
│           ├── 1 → INSERT INTO dependent ...
│           ├── 2 → UPDATE dependent SET ... WHERE Essn + Dependent_name
│           └── 3 → DELETE FROM dependent WHERE Essn + Dependent_name
│
└── ELSE → mensagem de entidade inválida
```

---

## Decisões de projeto

### Por que `IF` para entidade e `CASE` para ação?

- O `IF/ELSEIF/ELSE` é mais legível para um conjunto pequeno de entidades nomeadas (strings) e permite uma cláusula `ELSE` clara para entradas inválidas.
- O `CASE` é semanticamente mais preciso para uma variável numérica de controle com valores discretos e fixos (1, 2, 3), funcionando como um *switch* clássico.

### `COALESCE` no UPDATE — atualização parcial

No `UPDATE`, os campos usam `COALESCE(novo_valor, valor_atual)`. Isso significa que **passar `NULL` em um parâmetro preserva o valor existente**. A aplicação só precisa informar o SSN/Dnumber de identificação e os campos que deseja alterar.

```sql
-- Atualiza apenas o salário de '111223333'; todos os outros campos ficam intactos
CALL sp_company_manutencao(2, 'EMPLOYEE', '111223333', NULL, NULL, NULL,
     NULL, NULL, NULL, 38000.00, NULL, NULL, ...);
```

### `ROW_COUNT()` — validação de operação

Após cada `UPDATE` e `DELETE`, a procedure verifica `ROW_COUNT()`. Se nenhuma linha foi afetada, a mensagem de saída informa que o registro não foi encontrado, sem gerar erro fatal.

### Parâmetro `OUT p_mensagem`

Todas as ramificações definem `p_mensagem` com um texto descritivo do resultado. A aplicação pode capturar esse valor logo após o `CALL` com `SELECT @msg`.

---

## Exemplos de uso

### INSERT — novo funcionário

```sql
CALL sp_company_manutencao(
    1, 'EMPLOYEE',
    '111223333','Carlos','A','Souza','1990-04-10',
    '123-Main-Dallas-TX','M',35000.00,'333445555',5,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg; -- 'EMPLOYEE inserido com sucesso. SSN: 111223333'
```

### UPDATE — novo salário

```sql
CALL sp_company_manutencao(
    2, 'EMPLOYEE',
    '111223333', NULL, NULL, NULL, NULL, NULL, NULL, 38000.00, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg; -- 'EMPLOYEE atualizado com sucesso. SSN: 111223333'
```

### DELETE — remover funcionário

```sql
CALL sp_company_manutencao(
    3, 'EMPLOYEE',
    '111223333', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg; -- 'EMPLOYEE removido com sucesso. SSN: 111223333'
```

### INSERT — novo departamento

```sql
CALL sp_company_manutencao(
    1, 'DEPARTMENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'IT', 6, '333445555', '2024-03-01',
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg; -- 'DEPARTMENT inserido com sucesso. Número: 6'
```

### INSERT — novo dependente

```sql
CALL sp_company_manutencao(
    1, 'DEPENDENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '123456789', 'Laura', 'F', '2010-07-20', 'Daughter',
    @msg
);
SELECT @msg; -- 'DEPENDENT inserido: Laura (SSN func.: 123456789)'
```

---

Para verificar se a procedure foi criada:

```sql
SHOW PROCEDURE STATUS WHERE Db = 'company';
-- ou
SHOW CREATE PROCEDURE sp_company_manutencao;
```

---

# 👁️ Company Database — Views, Usuários e Triggers

## Sobre este módulo

Este módulo expande o projeto do banco `company` com três camadas de funcionalidade:

- **Views** — consultas pré-definidas que simplificam o acesso a informações consolidadas
- **Usuários** — controle de acesso baseado em função (*role-based*), garantindo que cada perfil veja apenas o que precisa
- **Triggers** — regras de negócio automáticas disparadas pelo próprio banco, sem depender da aplicação

---

## Views criadas

### `vw_employees_per_dept_location`
Número de empregados agrupados por departamento **e** localidade. Usa `LEFT JOIN` entre departamento, localizações e funcionários para não omitir departamentos sem nenhum funcionário alocado em determinada cidade.

```sql
SELECT * FROM vw_employees_per_dept_location;
```

| dept_name | location | total_employees |
|---|---|---|
| Administration | Stafford | 3 |
| Headquarters | Houston | 2 |
| Research | Bellaire | 3 |
| Research | Houston | 3 |
| Research | Sugarland | 3 |

---

### `vw_departments_managers`
Lista de departamentos com o nome completo do gerente e desde quando ele ocupa o cargo. Faz JOIN entre `departament` e `employee` pela coluna `Mgr_ssn`.

```sql
SELECT * FROM vw_departments_managers;
```

---

### `vw_projects_employee_count`
Ranking de projetos por número de funcionários alocados, incluindo total de horas. Útil para identificar projetos sobrecarregados ou sub-alocados.

```sql
SELECT * FROM vw_projects_employee_count;
```

---

### `vw_projects_dept_managers`
Cadeia completa: projeto → departamento responsável → gerente do departamento. Visão executiva para cruzar responsabilidades de projetos com a estrutura gerencial.

```sql
SELECT * FROM vw_projects_dept_managers;
```

---

### `vw_employees_dependents_managers`
Funcionários que possuem dependentes cadastrados, com a lista detalhada de cada dependente e um indicador (`SIM/NÃO`) se o funcionário é gerente de algum departamento. Usa `GROUP_CONCAT` para consolidar os dependentes em uma única linha por funcionário.

```sql
SELECT * FROM vw_employees_dependents_managers;
```

---

## Tabela de auditoria: `employee_fired`

Criada antes dos triggers. Espelha todas as colunas de `employee` e adiciona:

| Coluna extra | Descrição |
|---|---|
| `id` | PK auto-increment |
| `fired_at` | `DATETIME` do momento da exclusão |
| `fired_by` | Usuário MySQL que executou o `DELETE` (via `USER()`) |

Utiliza **InnoDB** (ao contrário do schema original em MyISAM) para garantir integridade transacional no histórico de demissões.

---

## Triggers

### `trg_employee_salary_raise` — BEFORE UPDATE

```
Tabela : employee
Evento : BEFORE UPDATE (FOR EACH ROW)
Regra  : se NEW.Dno = 5 (Research), força NEW.Salary = OLD.Salary * 1.20
```

**Por que `OLD.Salary * 1.20` e não `NEW.Salary * 1.20`?**

O valor de `NEW.Salary` no momento do `BEFORE UPDATE` já é o valor que veio do comando `UPDATE`. Se o reajuste fosse calculado sobre `NEW.Salary`, um `UPDATE` que já tentasse definir um valor maior poderia ter o percentual aplicado sobre um número diferente do salário real anterior. Usar `OLD.Salary` garante que **o reajuste é sempre 20% sobre o último salário registrado**, independentemente do que veio no `UPDATE`.

```sql
-- Exemplo: Franklin Wong ganha 42.000 → após UPDATE qualquer no dept 5
UPDATE employee SET Address = '700-New-Addr-TX' WHERE Ssn = '333445555';
-- Salary passa automaticamente para 50.400 (42000 * 1.20)
```

---

### `trg_employee_archive_fired` — BEFORE DELETE

```
Tabela : employee
Evento : BEFORE DELETE (FOR EACH ROW)
Regra  : copia OLD.* para employee_fired antes da linha ser apagada
```

**Por que BEFORE e não AFTER?**

Em MyISAM, `AFTER DELETE` funciona, mas em contextos com InnoDB e transações, usar `BEFORE` é mais seguro: se o `INSERT` na tabela de auditoria falhar, o `DELETE` também é bloqueado, garantindo que nenhum registro seja apagado sem antes ser arquivado.

```sql
-- Testar
INSERT INTO employee VALUES ('Test','X','User','000000001','2000-01-01','1-Test','M',30000,NULL,5);
DELETE FROM employee WHERE Ssn = '000000001';
SELECT * FROM employee_fired; -- registro aparece aqui
```

---

## Usuários e permissões

A política aplicada é **privilégio mínimo**: cada usuário recebe apenas as permissões que sua função exige.

### Mapa de acesso

| Usuário | Perfil | Views | Tabelas | Procedure |
|---|---|---|---|---|
| `dept_manager` | Gerente de Depto | `vw_employees_per_dept_location`, `vw_departments_managers` | — | `EXECUTE` |
| `hr_analyst` | Analista de RH | Todas exceto projetos | `employee` (CRUD), `dependent` (CRUD), `employee_fired` (leitura) | `EXECUTE` |
| `project_manager` | Gerente de Projeto | `vw_projects_employee_count`, `vw_projects_dept_managers` | — | — |
| `board_director` | Diretor | Todas as 5 views | — | — |
| `benefits_analyst` | Analista de Benefícios | `vw_employees_dependents_managers` | `dependent` (leitura) | — |

### Justificativa por perfil

**`dept_manager`** — O gerente precisa ver o headcount do seu departamento por localidade e conhecer os outros gerentes para contato. Não precisa alterar dados diretamente nas tabelas, mas pode usar a procedure para ajustes dentro de seu escopo.

**`hr_analyst`** — RH gerencia o ciclo completo do funcionário: admissão (INSERT), alterações (UPDATE) e desligamento (DELETE). Acessa o histórico de demitidos para rastreabilidade. Não acessa dados financeiros de projetos.

**`project_manager`** — Só precisa enxergar alocação de pessoal por projeto e qual departamento/gerente é responsável. Sem acesso a dados pessoais ou salariais.

**`board_director`** — Visão executiva de todas as informações consolidadas, sem permissão de modificação. Somente leitura em views garante que dados brutos não sejam expostos.

**`benefits_analyst`** — Trabalha exclusivamente com dependentes para gestão de planos de saúde e benefícios. Acessa a tabela `dependent` diretamente para consultas detalhadas, sem ver salários.

---

Verificar objetos criados:

```sql
-- Views
SHOW FULL TABLES IN company WHERE TABLE_TYPE = 'VIEW';

-- Triggers
SHOW TRIGGERS FROM company;

-- Usuários
SELECT user, host FROM mysql.user WHERE user IN
  ('dept_manager','hr_analyst','project_manager','board_director','benefits_analyst');
```

---

# 🚗 Car Rent — Banco de Dados MySQL

Projeto de estudo de banco de dados relacional para um sistema de aluguel de veículos, desenvolvido em MySQL. Abrange modelação de dados, transações, stored procedures, backup e recovery.

---

## 📁 Estrutura do Banco de Dados

O banco `car_rent` é composto por 5 tabelas:

| Tabela | Descrição |
|---|---|
| `clientes` | Dados dos clientes (nome, NCC, NIF) |
| `marcas` | Marcas dos veículos (ex: Renault, Ford) |
| `modelos` | Modelos associados a cada marca |
| `veiculos` | Veículos disponíveis para aluguer (matrícula + modelo) |
| `rent` | Registos de alugueres (cliente, veículo, datas) |

### Diagrama de Relações

```
clientes ──< rent >── veiculos ──< modelos >── marcas
```

---

## ⚙️ Configuração Inicial

### Pré-requisito: Engine InnoDB

O banco utiliza `InnoDB` para suporte completo a transações. O banco antes foi criado com `MyISAM`, então foi preciso converter com:

```sql
ALTER TABLE clientes ENGINE=InnoDB;
ALTER TABLE marcas   ENGINE=InnoDB;
ALTER TABLE modelos  ENGINE=InnoDB;
ALTER TABLE veiculos ENGINE=InnoDB;
ALTER TABLE rent     ENGINE=InnoDB;
```

> **Atenção:** O `MyISAM` ignora transações silenciosamente — `COMMIT` e `ROLLBACK` não têm efeito, por isso da conversão.

---

## 🔄 Transações

As transações garantem que um conjunto de operações seja executado de forma atómica — ou tudo é confirmado, ou nada é aplicado.

### Estrutura base

```sql
START TRANSACTION;

    -- operações SQL

COMMIT;   -- confirma tudo
-- ou
ROLLBACK; -- cancela tudo
```

### Uso de SAVEPOINT

```sql
START TRANSACTION;

    INSERT INTO marcas (nome_marca) VALUES ('Toyota');
    SAVEPOINT depois_da_marca;

    INSERT INTO modelos (nome, marca_id) VALUES ('Corolla', LAST_INSERT_ID());
    ROLLBACK TO depois_da_marca; -- desfaz só o modelo

COMMIT; -- confirma apenas a marca
```

---

## 🧩 Stored Procedure com Transaction

Procedure que regista um novo aluguer verificando conflitos de disponibilidade do veículo:

```sql
DELIMITER $$

CREATE PROCEDURE registrar_aluguel(
    IN p_person_id    SMALLINT UNSIGNED,
    IN p_veiculo_id   SMALLINT UNSIGNED,
    IN p_data_inicio  DATE,
    IN p_data_fim     DATE
)
BEGIN
    DECLARE conflito INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

        -- 1. Verificar disponibilidade do veículo
        SELECT COUNT(*) INTO conflito
        FROM rent
        WHERE veiculo_id = p_veiculo_id
          AND data_inicio < p_data_fim
          AND data_fim    > p_data_inicio;

        -- 2. Bloquear se houver conflito
        IF conflito > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Veículo indisponível nesse período.';
        END IF;

        -- 3. Inserir o aluguer
        INSERT INTO rent (data_inicio, data_fim, veiculo_id, person_id)
        VALUES (p_data_inicio, p_data_fim, p_veiculo_id, p_person_id);

    COMMIT;

    SELECT 'Aluguel registado com sucesso.' AS resultado;
END$$

DELIMITER ;
```

### Como chamar

```sql
-- Sucesso
CALL registar_aluguel(4, 3, '2026-08-01', '2026-08-05');

-- Erro — veículo indisponível no período
CALL registar_aluguel(1, 1, '2020-06-26', '2020-06-28');
```

### Gerir procedures

```sql
SHOW PROCEDURE STATUS WHERE Db = 'car_rent'; -- listar
SHOW CREATE PROCEDURE registar_aluguel;       -- ver código
DROP PROCEDURE IF EXISTS registar_aluguel;    -- apagar
```

![Recovery](M%C3%B3dulo5/imgs/procedure-sucesso.jpg)

---

## 💾 Backup

O backup é feito na linha de comandos com `mysqldump`.

```bash
# Backup completo (estrutura + dados + procedures)
mysqldump -u root -p --routines car_rent > backup_car_rent.sql

# Só estrutura
mysqldump -u root -p --no-data car_rent > estrutura_car_rent.sql

# Só dados
mysqldump -u root -p --no-create-info car_rent > dados_car_rent.sql

# Tabela específica
mysqldump -u root -p car_rent rent > backup_rent.sql

# Backup comprimido
mysqldump -u root -p --routines car_rent | gzip > backup_car_rent.sql.gz

# Backup com data no nome
mysqldump -u root -p car_rent > backup_$(date +%Y-%m-%d).sql
```

![Recovery](M%C3%B3dulo5/imgs/backup-cmd.jpg)

---

## ♻️ Recovery

### Via linha de comandos (CMD)

```bash
# 1. Localizar a pasta com o ficheiro do backup

# 2. Restaurar
mysql -u root -p car_rent < backup_car_rent.sql

![Recovery](Módulo5/imgs/recovery-cmd.jpg)

```

### Verificar o recovery

```sql
USE car_rent;
SHOW TABLES;
SELECT * FROM clientes;
SELECT * FROM rent;
```

---

## 🛠️ Tecnologias

- MySQL 8+
- MySQL Workbench
- mysqldump (backup/recovery)
- Engine InnoDB (transações)

---

## 📌 Conceitos Abordados

- Modelação relacional com chaves primárias e estrangeiras
- Transações ACID com `START TRANSACTION`, `COMMIT`, `ROLLBACK` e `SAVEPOINT`
- Stored Procedures com parâmetros de entrada e tratamento de erros (`SIGNAL`, `EXIT HANDLER`)
- Backup completo e parcial com `mysqldump`
- Recovery via CMD e MySQL Workbench

## Tecnologias

- MySQL 9.1 / phpMyAdmin 5.2.1
- Motor: MyISAM
- Tipo de índice: BTREE
