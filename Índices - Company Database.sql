use company;

-- =============================================================================
-- COMPANY DATABASE - ÍNDICES E QUERIES
-- =============================================================================
-- CRITÉRIOS PARA CRIAÇÃO DE ÍNDICES:
--   1. Colunas usadas em JOIN (FK que não têm índice automático no MyISAM)
--   2. Colunas usadas em GROUP BY / ORDER BY / WHERE com alta cardinalidade
--   3. Evitar índices em colunas com baixa cardinalidade (ex: Sex char(1))
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TABELA: employee
-- -----------------------------------------------------------------------------

-- Dno (número do departamento) é FK usada em JOIN e GROUP BY nas 3 perguntas.
-- Cardinalidade média (3 departamentos para 8 funcionários), mas o índice é
-- essencial para evitar full scan quando a tabela crescer.
-- Tipo BTREE (padrão): suporta buscas de igualdade e range, adequado para
-- colunas numéricas agrupadas.
CREATE INDEX idx_employee_dno ON employee(Dno) USING BTREE;

-- super_ssn é FK sem índice automático no MyISAM; útil para consultas
-- hierárquicas (quem supervisiona quem). Não é exigida pelas 3 queries
-- principais, mas tem valor contextual elevado no schema.
CREATE INDEX idx_employee_super_ssn ON employee(super_ssn) USING BTREE;


-- -----------------------------------------------------------------------------
-- TABELA: departament
-- -----------------------------------------------------------------------------

-- Dnumber é PK → já possui índice automático. Nenhum índice adicional
-- Mgr_ssn já possui KEY declarada no CREATE TABLE (índice existente).


-- -----------------------------------------------------------------------------
-- TABELA: dept_locations
-- -----------------------------------------------------------------------------

-- Dnumber é parte da PK composta (Dnumber, Dlocation) → já indexado.
-- Dlocation: coluna de cidade usada em filtros de busca por localização.
-- Cardinalidade razoável (cidades distintas). Índice BTREE permite buscas
-- por prefixo e ordenação alfabética eficiente.
CREATE INDEX idx_dept_locations_dlocation ON dept_locations(Dlocation) USING BTREE;


-- =============================================================================
-- QUERY 1: Qual o departamento com maior número de pessoas?
-- Tabelas envolvidas: employee, departament
-- Índice utilizado: idx_employee_dno (agrupa employee por Dno sem full scan)
-- =============================================================================
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


-- =============================================================================
-- QUERY 2: Quais os departamentos por cidade?
-- Tabelas envolvidas: departament, dept_locations
-- Índice utilizado: PK composta de dept_locations já cobre o JOIN por Dnumber;
--                  idx_dept_locations_dlocation acelera ORDER BY Dlocation
-- =============================================================================
SELECT
    dl.Dlocation   AS Cidade,
    d.Dname        AS Departamento
FROM
    dept_locations dl
    JOIN departament d ON dl.Dnumber = d.Dnumber
ORDER BY
    dl.Dlocation, d.Dname;


-- =============================================================================
-- QUERY 3: Relação de empregados por departamento
-- Tabelas envolvidas: employee, departament
-- Índice utilizado: idx_employee_dno (lookup/agrupamento por Dno)
-- =============================================================================
SELECT
    d.Dname                                         AS Departamento,
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname)    AS Funcionario,
    e.Salary                                        AS Salario
FROM
    employee e
    JOIN departament d ON e.Dno = d.Dnumber
ORDER BY
    d.Dname, e.Lname, e.Fname;
    
    
-- -----------------------------------------------------------------------------
-- EXPLAIN: verificar se os índices estão sendo usados pelo otimizador
-- -----------------------------------------------------------------------------
    
EXPLAIN SELECT d.Dname, COUNT(e.Ssn) FROM employee e
   JOIN departament d ON e.Dno = d.Dnumber
   GROUP BY d.Dnumber ORDER BY 2 DESC LIMIT 1;