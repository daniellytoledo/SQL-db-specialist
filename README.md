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


<img width="978" height="995" alt="e-commerce" src="https://github.com/user-attachments/assets/ce93ee00-0f7b-4a1a-8efe-5c47e6bd7bf3" />


2. Oficina mecânica (Módulo 2 - Modelo de Dados Relacionais):

<img width="982" height="875" alt="Oficina" src="https://github.com/user-attachments/assets/58b08f93-3f01-45aa-8839-99f946528fee" />

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

## Tecnologias

- MySQL 9.1 / phpMyAdmin 5.2.1
- Motor: MyISAM
- Tipo de índice: BTREE
