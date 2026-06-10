-- =============================================================================
-- COMPANY DATABASE - VIEWS, USUÁRIOS E TRIGGERS
-- =============================================================================

use company;

-- =============================================================================
-- SEÇÃO 1: VIEWS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- VIEW 1: Número de empregados por departamento e localidade
-- Contexto: Útil para gerentes e RH visualizarem distribuição de pessoal
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_employees_per_dept_location AS
SELECT
    d.Dnumber                   AS dept_number,
    d.Dname                     AS dept_name,
    dl.Dlocation                AS location,
    COUNT(e.Ssn)                AS total_employees
FROM
    departament d
    JOIN dept_locations dl  ON d.Dnumber  = dl.Dnumber
    LEFT JOIN employee e    ON e.Dno      = d.Dnumber
GROUP BY
    d.Dnumber, d.Dname, dl.Dlocation
ORDER BY
    d.Dname, dl.Dlocation;


-- -----------------------------------------------------------------------------
-- VIEW 2: Lista de departamentos e seus gerentes
-- Contexto: Diretoria e RH consultam quem gerencia cada departamento
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_departments_managers AS
SELECT
    d.Dnumber                                           AS dept_number,
    d.Dname                                             AS dept_name,
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname)       AS manager_name,
    e.Ssn                                               AS manager_ssn,
    d.Mgr_start_date                                    AS manager_since
FROM
    departament d
    JOIN employee e ON d.Mgr_ssn = e.Ssn
ORDER BY
    d.Dname;


-- -----------------------------------------------------------------------------
-- VIEW 3: Projetos com maior número de empregados (ranking decrescente)
-- Contexto: Gerentes de projeto e diretoria acompanham alocação por projeto
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_projects_employee_count AS
SELECT
    p.Pnumber                   AS project_number,
    p.Pname                     AS project_name,
    p.Plocation                 AS project_location,
    d.Dname                     AS responsible_dept,
    COUNT(wo.Essn)              AS total_employees,
    SUM(wo.Hours)               AS total_hours
FROM
    project p
    JOIN departament d  ON p.Dnum   = d.Dnumber
    LEFT JOIN works_on wo ON p.Pnumber = wo.Pno
GROUP BY
    p.Pnumber, p.Pname, p.Plocation, d.Dname
ORDER BY
    total_employees DESC, total_hours DESC;


-- -----------------------------------------------------------------------------
-- VIEW 4: Lista de projetos, departamentos e gerentes
-- Contexto: Diretoria e auditoria enxergam a cadeia projeto → depto → gerente
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_projects_dept_managers AS
SELECT
    p.Pnumber                                           AS project_number,
    p.Pname                                             AS project_name,
    p.Plocation                                         AS project_location,
    d.Dname                                             AS dept_name,
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname)       AS manager_name,
    e.Ssn                                               AS manager_ssn,
    d.Mgr_start_date                                    AS manager_since
FROM
    project p
    JOIN departament d  ON p.Dnum    = d.Dnumber
    JOIN employee   e  ON d.Mgr_ssn  = e.Ssn
ORDER BY
    p.Pname;


-- -----------------------------------------------------------------------------
-- VIEW 5: Empregados com dependentes e se são gerentes de departamento
-- Contexto: RH e benefícios consultam quem tem dependentes; identifica gerentes
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_employees_dependents_managers AS
SELECT
    CONCAT(e.Fname, ' ', e.Minit, '. ', e.Lname)       AS employee_name,
    e.Ssn                                               AS employee_ssn,
    d.Dname                                             AS dept_name,
    COUNT(dep.Dependent_name)                           AS total_dependents,
    GROUP_CONCAT(
        dep.Dependent_name, ' (', dep.Relationship, ')'
        ORDER BY dep.Dependent_name
        SEPARATOR ', '
    )                                                   AS dependents_detail,
    CASE
        WHEN dept_mgr.Mgr_ssn IS NOT NULL THEN 'SIM'
        ELSE 'NÃO'
    END                                                 AS is_manager
FROM
    employee e
    JOIN departament d          ON e.Dno = d.Dnumber
    JOIN dependent dep          ON dep.Essn = e.Ssn
    LEFT JOIN departament dept_mgr ON dept_mgr.Mgr_ssn = e.Ssn
GROUP BY
    e.Ssn, e.Fname, e.Minit, e.Lname, d.Dname, dept_mgr.Mgr_ssn
ORDER BY
    is_manager DESC, employee_name;


-- =============================================================================
-- SEÇÃO 2: TABELA DE AUDITORIA (necessária antes dos triggers)
-- =============================================================================

-- Tabela que armazena empregados demitidos (usada pelo trigger BEFORE DELETE)
CREATE TABLE IF NOT EXISTS employee_fired (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    fired_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fired_by        VARCHAR(100)    NOT NULL DEFAULT (USER()),   -- usuário MySQL que executou o DELETE
    -- espelho das colunas de employee
    Ssn             CHAR(9)         NOT NULL,
    Fname           VARCHAR(15),
    Minit           CHAR(1),
    Lname           VARCHAR(15),
    Bdate           DATE,
    Address         VARCHAR(30),
    sex             CHAR(1),
    Salary          DECIMAL(10,2),
    super_ssn       CHAR(9),
    Dno             INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================================
-- SEÇÃO 3: TRIGGERS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TRIGGER 1: BEFORE UPDATE em employee
-- Regra: se o empregado pertence ao departamento 5 (Research),
--        o novo salário recebe reajuste de 20% automaticamente,
--        independentemente do valor informado no UPDATE.
-- -----------------------------------------------------------------------------
DELIMITER $$

DROP TRIGGER IF EXISTS trg_employee_salary_raise$$

CREATE TRIGGER trg_employee_salary_raise
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    -- Aplica reajuste apenas para o departamento Research (Dno = 5)
    -- Verifica tanto o Dno atual quanto o novo (caso o UPDATE mude o depto)
    IF NEW.Dno = 5 THEN
        -- Garante que o salário seja sempre 20% acima do valor ANTERIOR ao UPDATE,
        -- evitando que um UPDATE sem intenção de mexer no salário aplique
        -- o percentual sobre o valor já reajustado numa atualização anterior.
        SET NEW.Salary = OLD.Salary * 1.20;
    END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------------------------------
-- TRIGGER 2: BEFORE DELETE em employee
-- Regra: antes de remover qualquer empregado, copia todos os atributos
--        (OLD.*) para a tabela employee_fired, registrando quem e quando deletou.
-- -----------------------------------------------------------------------------
DELIMITER $$

DROP TRIGGER IF EXISTS trg_employee_archive_fired$$

CREATE TRIGGER trg_employee_archive_fired
BEFORE DELETE ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_fired
        (fired_at, fired_by,
         Ssn, Fname, Minit, Lname, Bdate, Address, sex, Salary, super_ssn, Dno)
    VALUES
        (NOW(), USER(),
         OLD.Ssn, OLD.Fname, OLD.Minit, OLD.Lname, OLD.Bdate,
         OLD.Address, OLD.sex, OLD.Salary, OLD.super_ssn, OLD.Dno);
END$$

DELIMITER ;


-- =============================================================================
-- SEÇÃO 4: USUÁRIOS E PERMISSÕES
-- =============================================================================
-- Política de privilégios:
-- cada usuário recebe apenas o acesso que sua função exige.
-- =============================================================================

-- Garante reset limpo em re-execuções
DROP USER IF EXISTS 'dept_manager'@'localhost';
DROP USER IF EXISTS 'hr_analyst'@'localhost';
DROP USER IF EXISTS 'project_manager'@'localhost';
DROP USER IF EXISTS 'board_director'@'localhost';
DROP USER IF EXISTS 'benefits_analyst'@'localhost';
DROP USER IF EXISTS 'dba_company'@'localhost';


-- -----------------------------------------------------------------------------
-- USUÁRIO 1: dept_manager (Gerente de Departamento)
-- Acesso: leitura nas views de headcount e lista de gerentes
-- Justificativa: o gerente precisa ver quantos funcionários estão em seu depto
--                por localidade e quem gerencia os outros deptos para contato.
-- -----------------------------------------------------------------------------
CREATE USER 'dept_manager'@'localhost' IDENTIFIED BY 'DeptMgr@2024!';

GRANT SELECT ON company.vw_employees_per_dept_location   TO 'dept_manager'@'localhost';
GRANT SELECT ON company.vw_departments_managers          TO 'dept_manager'@'localhost';
GRANT EXECUTE ON PROCEDURE company.sp_company_manutencao TO 'dept_manager'@'localhost'; -- ERRO


-- -----------------------------------------------------------------------------
-- USUÁRIO 2: hr_analyst (Analista de RH)
-- Acesso: leitura em todas as views + INSERT/UPDATE/DELETE em employee e dependent
--         + leitura em employee_fired (histórico de demissões)
-- Justificativa: RH gerencia o ciclo de vida do funcionário (admissão,
--                alterações cadastrais, demissão) e precisa de visibilidade total.
-- -----------------------------------------------------------------------------
CREATE USER 'hr_analyst'@'localhost' IDENTIFIED BY 'HrAnalyst@2024!';

GRANT SELECT ON company.vw_employees_per_dept_location    TO 'hr_analyst'@'localhost';
GRANT SELECT ON company.vw_departments_managers           TO 'hr_analyst'@'localhost';
GRANT SELECT ON company.vw_employees_dependents_managers  TO 'hr_analyst'@'localhost';
GRANT SELECT ON company.employee_fired                    TO 'hr_analyst'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON company.employee  TO 'hr_analyst'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON company.dependent TO 'hr_analyst'@'localhost';


-- -----------------------------------------------------------------------------
-- USUÁRIO 3: project_manager (Gerente de Projeto)
-- Acesso: leitura nas views de projetos
-- Justificativa: acompanha alocação de pessoas por projeto mas não
--                altera dados de funcionários ou departamentos.
-- -----------------------------------------------------------------------------
CREATE USER 'project_manager'@'localhost' IDENTIFIED BY 'ProjMgr@2024!';

GRANT SELECT ON company.vw_projects_employee_count TO 'project_manager'@'localhost';
GRANT SELECT ON company.vw_projects_dept_managers  TO 'project_manager'@'localhost';


-- -----------------------------------------------------------------------------
-- USUÁRIO 4: board_director (Diretor / Alta Gestão)
-- Acesso: leitura somente em todas as views (visão executiva, sem alteração)
-- Justificativa: diretores consomem informações consolidadas para tomada
--                de decisão, sem necessidade de modificar dados.
-- -----------------------------------------------------------------------------
CREATE USER 'board_director'@'localhost' IDENTIFIED BY 'BoardDir@2024!';

GRANT SELECT ON company.vw_employees_per_dept_location   TO 'board_director'@'localhost';
GRANT SELECT ON company.vw_departments_managers          TO 'board_director'@'localhost';
GRANT SELECT ON company.vw_projects_employee_count       TO 'board_director'@'localhost';
GRANT SELECT ON company.vw_projects_dept_managers        TO 'board_director'@'localhost';
GRANT SELECT ON company.vw_employees_dependents_managers TO 'board_director'@'localhost';


-- -----------------------------------------------------------------------------
-- USUÁRIO 5: benefits_analyst (Analista de Benefícios)
-- Acesso: leitura na view de dependentes/gerentes + tabela dependent
-- Justificativa: responsável por planos de saúde e benefícios precisa saber
--                quem tem dependentes sem acesso a dados salariais.
-- -----------------------------------------------------------------------------
CREATE USER 'benefits_analyst'@'localhost' IDENTIFIED BY 'Benefits@2024!';

GRANT SELECT ON company.vw_employees_dependents_managers TO 'benefits_analyst'@'localhost';
GRANT SELECT ON company.dependent                        TO 'benefits_analyst'@'localhost';


-- -----------------------------------------------------------------------------
-- USUÁRIO 6: dba_company (DBA / Administrador do Banco)
-- Acesso: todos os privilégios no schema company
-- Justificativa: responsável pela manutenção, tuning e segurança do banco.
-- -----------------------------------------------------------------------------

DROP USER IF EXISTS 'dba_company'@'localhost';
CREATE USER 'dba_company'@'localhost' IDENTIFIED BY 'DbaComp@2024!';

GRANT ALL PRIVILEGES ON company.* TO 'dba_company'@'localhost' WITH GRANT OPTION;


-- =============================================================================
-- VERIFICAÇÕES / TESTES
-- =============================================================================

-- Consultar todas as views
SELECT * FROM vw_employees_per_dept_location;
SELECT * FROM vw_departments_managers;
SELECT * FROM vw_projects_employee_count;
SELECT * FROM vw_projects_dept_managers;
SELECT * FROM vw_employees_dependents_managers;

-- Testar trigger de reajuste (dept 5 = Research)
UPDATE employee SET Salary = Salary WHERE Ssn = '333445555'; -- Franklin Wong, Dno=5

SELECT Ssn, Fname, Salary FROM employee WHERE Ssn = '333445555';

-- Testar trigger de arquivo de demitidos
-- (Primeiro insira um funcionário temporário para não perder dados reais)

INSERT INTO employee VALUES
    ('Test','X','User','000000001','2000-01-01','1-Test-Street','M',30000.00,'333445555',5);
    
DELETE FROM employee WHERE Ssn = '000000001';

SELECT * FROM employee_fired;