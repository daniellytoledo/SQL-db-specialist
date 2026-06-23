-- =============================================================================
-- COMPANY DATABASE - STORED PROCEDURE DE MANUTENÇÃO
-- =============================================================================
-- DESCRIÇÃO:
--   Uma única procedure centraliza as operações de INSERT, UPDATE e DELETE
--   para as principais entidades do banco. Uma variável de controle (p_acao)
--   determina qual operação será executada. Estruturas IF/CASE garantem que
--   apenas a ação solicitada seja disparada.
--
-- VARIÁVEL DE CONTROLE (p_acao):
--   1 = INSERT   — insere um novo registro
--   2 = UPDATE   — atualiza dados de um registro existente
--   3 = DELETE   — remove um registro existente
--
-- ENTIDADES SUPORTADAS (p_entidade):
--   'EMPLOYEE'    — tabela employee
--   'DEPARTMENT'  — tabela departament
--   'DEPENDENT'   — tabela dependent
-- =============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_company_manutencao$$

CREATE PROCEDURE sp_company_manutencao(

    -- -------------------------------------------------------------------------
    -- VARIÁVEL DE CONTROLE
    -- -------------------------------------------------------------------------
    IN p_acao      TINYINT,      -- 1=INSERT | 2=UPDATE | 3=DELETE
    IN p_entidade  VARCHAR(20),  -- 'EMPLOYEE' | 'DEPARTMENT' | 'DEPENDENT'

    -- -------------------------------------------------------------------------
    -- PARÂMETROS: EMPLOYEE
    -- -------------------------------------------------------------------------
    IN p_emp_ssn        CHAR(9),
    IN p_emp_fname      VARCHAR(15),
    IN p_emp_minit      CHAR(1),
    IN p_emp_lname      VARCHAR(15),
    IN p_emp_bdate      DATE,
    IN p_emp_address    VARCHAR(30),
    IN p_emp_sex        CHAR(1),
    IN p_emp_salary     DECIMAL(10,2),
    IN p_emp_super_ssn  CHAR(9),
    IN p_emp_dno        INT,

    -- -------------------------------------------------------------------------
    -- PARÂMETROS: DEPARTAMENT
    -- -------------------------------------------------------------------------
    IN p_dept_dname       VARCHAR(15),
    IN p_dept_dnumber     INT,
    IN p_dept_mgr_ssn     CHAR(9),
    IN p_dept_mgr_start   DATE,

    -- -------------------------------------------------------------------------
    -- PARÂMETROS: DEPENDENT
    -- -------------------------------------------------------------------------
    IN p_dep_essn          CHAR(9),
    IN p_dep_name          VARCHAR(15),
    IN p_dep_sex           CHAR(1),
    IN p_dep_bdate         DATE,
    IN p_dep_relationship  VARCHAR(8),

    -- -------------------------------------------------------------------------
    -- PARÂMETRO DE SAÍDA: mensagem de retorno para a aplicação
    -- -------------------------------------------------------------------------
    OUT p_mensagem VARCHAR(200)
)
BEGIN

    -- =========================================================================
    -- BLOCO PRINCIPAL: IF sobre p_entidade → CASE sobre p_acao
    -- =========================================================================

    -- -----------------------------------------
    -- ENTIDADE: EMPLOYEE
    -- -----------------------------------------
    IF UPPER(p_entidade) = 'EMPLOYEE' THEN

        CASE p_acao

            -- INSERT employee
            WHEN 1 THEN
                INSERT INTO employee
                    (Fname, Minit, Lname, Ssn, Bdate, Address, sex, Salary, super_ssn, Dno)
                VALUES
                    (p_emp_fname, p_emp_minit, p_emp_lname, p_emp_ssn,
                     p_emp_bdate, p_emp_address, p_emp_sex,
                     p_emp_salary, p_emp_super_ssn, p_emp_dno);

                SET p_mensagem = CONCAT('EMPLOYEE inserido com sucesso. SSN: ', p_emp_ssn);

            -- UPDATE employee  (identifica pelo SSN; atualiza salário, endereço e supervisor)
            WHEN 2 THEN
                UPDATE employee
                SET
                    Fname      = COALESCE(NULLIF(p_emp_fname,   ''), Fname),
                    Minit      = COALESCE(NULLIF(p_emp_minit,   ''), Minit),
                    Lname      = COALESCE(NULLIF(p_emp_lname,   ''), Lname),
                    Bdate      = COALESCE(p_emp_bdate,              Bdate),
                    Address    = COALESCE(NULLIF(p_emp_address, ''), Address),
                    sex        = COALESCE(NULLIF(p_emp_sex,     ''), sex),
                    Salary     = COALESCE(p_emp_salary,             Salary),
                    super_ssn  = COALESCE(NULLIF(p_emp_super_ssn,''),super_ssn),
                    Dno        = COALESCE(p_emp_dno,                Dno)
                WHERE Ssn = p_emp_ssn;

                IF ROW_COUNT() = 0 THEN
                    SET p_mensagem = CONCAT('EMPLOYEE não encontrado para UPDATE. SSN: ', p_emp_ssn);
                ELSE
                    SET p_mensagem = CONCAT('EMPLOYEE atualizado com sucesso. SSN: ', p_emp_ssn);
                END IF;

            -- DELETE employee
            WHEN 3 THEN
                DELETE FROM employee WHERE Ssn = p_emp_ssn;

                IF ROW_COUNT() = 0 THEN
                    SET p_mensagem = CONCAT('EMPLOYEE não encontrado para DELETE. SSN: ', p_emp_ssn);
                ELSE
                    SET p_mensagem = CONCAT('EMPLOYEE removido com sucesso. SSN: ', p_emp_ssn);
                END IF;

            ELSE
                SET p_mensagem = 'Ação inválida para EMPLOYEE. Use 1=INSERT, 2=UPDATE, 3=DELETE.';

        END CASE;

    -- -----------------------------------------
    -- ENTIDADE: DEPARTMENT
    -- -----------------------------------------
    ELSEIF UPPER(p_entidade) = 'DEPARTMENT' THEN

        CASE p_acao

            -- INSERT department
            WHEN 1 THEN
                INSERT INTO departament
                    (Dname, Dnumber, Mgr_ssn, Mgr_start_date)
                VALUES
                    (p_dept_dname, p_dept_dnumber, p_dept_mgr_ssn, p_dept_mgr_start);

                SET p_mensagem = CONCAT('DEPARTMENT inserido com sucesso. Número: ', p_dept_dnumber);

            -- UPDATE department (identifica pelo Dnumber; atualiza nome, gerente e data de início)
            WHEN 2 THEN
                UPDATE departament
                SET
                    Dname          = COALESCE(NULLIF(p_dept_dname,    ''), Dname),
                    Mgr_ssn        = COALESCE(NULLIF(p_dept_mgr_ssn,  ''), Mgr_ssn),
                    Mgr_start_date = COALESCE(p_dept_mgr_start,           Mgr_start_date)
                WHERE Dnumber = p_dept_dnumber;

                IF ROW_COUNT() = 0 THEN
                    SET p_mensagem = CONCAT('DEPARTMENT não encontrado para UPDATE. Número: ', p_dept_dnumber);
                ELSE
                    SET p_mensagem = CONCAT('DEPARTMENT atualizado com sucesso. Número: ', p_dept_dnumber);
                END IF;

            -- DELETE department
            WHEN 3 THEN
                DELETE FROM departament WHERE Dnumber = p_dept_dnumber;

                IF ROW_COUNT() = 0 THEN
                    SET p_mensagem = CONCAT('DEPARTMENT não encontrado para DELETE. Número: ', p_dept_dnumber);
                ELSE
                    SET p_mensagem = CONCAT('DEPARTMENT removido com sucesso. Número: ', p_dept_dnumber);
                END IF;

            ELSE
                SET p_mensagem = 'Ação inválida para DEPARTMENT. Use 1=INSERT, 2=UPDATE, 3=DELETE.';

        END CASE;

    -- -----------------------------------------
    -- ENTIDADE: DEPENDENT
    -- -----------------------------------------
    ELSEIF UPPER(p_entidade) = 'DEPENDENT' THEN

        CASE p_acao

            -- INSERT dependent
            WHEN 1 THEN
                INSERT INTO dependent
                    (Essn, Dependent_name, Sex, Bdate, Relationship)
                VALUES
                    (p_dep_essn, p_dep_name, p_dep_sex, p_dep_bdate, p_dep_relationship);

                SET p_mensagem = CONCAT('DEPENDENT inserido: ', p_dep_name, ' (SSN func.: ', p_dep_essn, ')');

            -- UPDATE dependent (PK composta: Essn + Dependent_name)
            WHEN 2 THEN
                UPDATE dependent
                SET
                    Sex          = COALESCE(NULLIF(p_dep_sex,          ''), Sex),
                    Bdate        = COALESCE(p_dep_bdate,                    Bdate),
                    Relationship = COALESCE(NULLIF(p_dep_relationship, ''), Relationship)
                WHERE Essn = p_dep_essn AND Dependent_name = p_dep_name;

                IF ROW_COUNT() = 0 THEN
                    SET p_mensagem = CONCAT('DEPENDENT não encontrado para UPDATE. Nome: ', p_dep_name);
                ELSE
                    SET p_mensagem = CONCAT('DEPENDENT atualizado com sucesso. Nome: ', p_dep_name);
                END IF;

            -- DELETE dependent
            WHEN 3 THEN
                DELETE FROM dependent
                WHERE Essn = p_dep_essn AND Dependent_name = p_dep_name;

                IF ROW_COUNT() = 0 THEN
                    SET p_mensagem = CONCAT('DEPENDENT não encontrado para DELETE. Nome: ', p_dep_name);
                ELSE
                    SET p_mensagem = CONCAT('DEPENDENT removido com sucesso. Nome: ', p_dep_name);
                END IF;

            ELSE
                SET p_mensagem = 'Ação inválida para DEPENDENT. Use 1=INSERT, 2=UPDATE, 3=DELETE.';

        END CASE;

    -- -----------------------------------------
    -- ENTIDADE NÃO RECONHECIDA
    -- -----------------------------------------
    ELSE
        SET p_mensagem = CONCAT('Entidade desconhecida: "', p_entidade,
                                '". Use EMPLOYEE, DEPARTMENT ou DEPENDENT.');
    END IF;

END$$

DELIMITER ;


-- =============================================================================
-- EXEMPLOS DE USO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- EMPLOYEE — INSERT
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    1, 'EMPLOYEE',
    -- employee
    '111223333','Carlos','A','Souza','1990-04-10','123-Main-Dallas-TX','M',35000.00,'333445555',5,
    -- department (não usado)
    NULL, NULL, NULL, NULL,
    -- dependent (não usado)
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- EMPLOYEE — UPDATE (atualiza apenas salário; demais campos preservados via COALESCE)
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    2, 'EMPLOYEE',
    -- SSN obrigatório para identificar o registro
    '111223333', NULL, NULL, NULL, NULL, NULL, NULL, 38000.00, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- EMPLOYEE — DELETE
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    3, 'EMPLOYEE',
    '111223333', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- DEPARTMENT — INSERT
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    1, 'DEPARTMENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'IT', 6, '333445555', '2024-03-01',
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- DEPARTMENT — UPDATE (troca o gerente)
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    2, 'DEPARTMENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, 6, '888665555', '2025-01-15',
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- DEPARTMENT — DELETE
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    3, 'DEPARTMENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, 6, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- DEPENDENT — INSERT
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    1, 'DEPENDENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '123456789', 'Laura', 'F', '2010-07-20', 'Daughter',
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- DEPENDENT — UPDATE
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    2, 'DEPENDENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '123456789', 'Laura', NULL, '2010-07-22', 'Daughter',
    @msg
);
SELECT @msg AS Resultado;

-- -----------------------------------------------------------------------------
-- DEPENDENT — DELETE
-- -----------------------------------------------------------------------------
CALL sp_company_manutencao(
    3, 'DEPENDENT',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '123456789', 'Laura', NULL, NULL, NULL,
    @msg
);
SELECT @msg AS Resultado;