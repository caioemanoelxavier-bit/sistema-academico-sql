-- 02_triggers_regras_negocio.sql
USE sisgesc;

DROP TRIGGER IF EXISTS trg_rn01_matricula_contrato_ativo;
DROP TRIGGER IF EXISTS trg_rn02_nota_matricula_ativa;
DROP TRIGGER IF EXISTS trg_rn03_gerar_mensalidades;
DROP TRIGGER IF EXISTS trg_rn04_limite_vagas;
DROP TRIGGER IF EXISTS trg_rn05_professor_funcionario_ativo;

DELIMITER $$

-- RN-01: aluno so pode se matricular se tiver contrato ativo no mesmo curso da turma.
CREATE TRIGGER trg_rn01_matricula_contrato_ativo
BEFORE INSERT ON tb_matricula
FOR EACH ROW
BEGIN
    DECLARE v_curso INT;
    DECLARE v_total_contratos INT;

    SELECT d.fk_curso INTO v_curso
    FROM tb_turma t
    INNER JOIN tb_disciplina d ON d.pk_disciplina = t.fk_disciplina
    WHERE t.pk_turma = NEW.fk_turma;

    SELECT COUNT(*) INTO v_total_contratos
    FROM tb_contrato c
    WHERE c.fk_rgm = NEW.fk_rgm
      AND c.fk_curso = v_curso
      AND c.status = 'ativo';

    IF v_total_contratos = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN-01 violada: aluno nao possui contrato ativo para o curso da turma.';
    END IF;
END$$

-- RN-02: nota so pode ser lancada em matricula ativa.
CREATE TRIGGER trg_rn02_nota_matricula_ativa
BEFORE INSERT ON tb_nota
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM tb_matricula
    WHERE pk_matricula = NEW.fk_matricula;

    IF v_status <> 'ativa' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN-02 violada: nota so pode ser lancada em matricula ativa.';
    END IF;
END$$

-- RN-03: gerar 12 mensalidades automaticamente ao ativar contrato.
CREATE TRIGGER trg_rn03_gerar_mensalidades
AFTER INSERT ON tb_contrato
FOR EACH ROW
BEGIN
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_data_ref DATE;
    DECLARE v_valor_desconto DECIMAL(10,2);
    DECLARE v_valor_liquido DECIMAL(10,2);

    IF NEW.status = 'ativo' THEN
        SET v_valor_desconto = ROUND(NEW.vlr_mensalidade * (NEW.desconto_pct / 100), 2);
        SET v_valor_liquido = NEW.vlr_mensalidade - v_valor_desconto;

        WHILE v_i < 12 DO
            SET v_data_ref = DATE_ADD(NEW.dt_inicio, INTERVAL v_i MONTH);

            INSERT IGNORE INTO tb_mensalidade (
                fk_contrato, mes_ref, ano_ref, vlr_bruto, vlr_desconto,
                vlr_liquido, dt_vencimento, status
            ) VALUES (
                NEW.pk_contrato,
                MONTH(v_data_ref),
                YEAR(v_data_ref),
                NEW.vlr_mensalidade,
                v_valor_desconto,
                v_valor_liquido,
                DATE_ADD(v_data_ref, INTERVAL 9 DAY),
                'pendente'
            );

            SET v_i = v_i + 1;
        END WHILE;
    END IF;
END$$

-- RN-04: total de matriculas ativas nao pode ultrapassar vagas da turma.
CREATE TRIGGER trg_rn04_limite_vagas
BEFORE INSERT ON tb_matricula
FOR EACH ROW
BEGIN
    DECLARE v_vagas INT;
    DECLARE v_ocupadas INT;

    SELECT vagas INTO v_vagas
    FROM tb_turma
    WHERE pk_turma = NEW.fk_turma;

    SELECT COUNT(*) INTO v_ocupadas
    FROM tb_matricula
    WHERE fk_turma = NEW.fk_turma
      AND status = 'ativa';

    IF NEW.status = 'ativa' AND v_ocupadas >= v_vagas THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN-04 violada: limite de vagas da turma atingido.';
    END IF;
END$$

-- RN-05: professor precisa ser funcionario ativo.
CREATE TRIGGER trg_rn05_professor_funcionario_ativo
BEFORE INSERT ON tb_professor
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM tb_funcionario
    WHERE pk_funcionario = NEW.fk_funcionario;

    IF v_status <> 'ativo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN-05 violada: professor deve estar vinculado a funcionario ativo.';
    END IF;
END$$

DELIMITER ;
