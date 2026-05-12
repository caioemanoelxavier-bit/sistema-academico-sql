-- 03_dml_carga_dados_idempotente.sql
-- Carga operacional. Pode ser executada varias vezes sem alterar a quantidade de registros.
USE sisgesc;

-- Pessoas: funcionarios e alunos
INSERT IGNORE INTO tb_pessoa (pk_cpf, rg, dt_nascimento, genero) VALUES
('11111111111', 'RG111111', '1980-04-10', 'M'),
('22222222222', 'RG222222', '1985-08-22', 'F'),
('33333333333', 'RG333333', '2001-03-14', 'M'),
('44444444444', 'RG444444', '2002-07-25', 'F'),
('55555555555', 'RG555555', '2000-11-05', 'Outro');

-- RH
INSERT IGNORE INTO tb_departamento (pk_departamento, nome, descricao) VALUES
(1, 'Academico', 'Gestao de cursos, disciplinas e turmas'),
(2, 'Financeiro', 'Gestao de contratos, mensalidades e pagamentos'),
(3, 'Recursos Humanos', 'Gestao de colaboradores e professores');

INSERT IGNORE INTO tb_cargo (pk_cargo, nome, salario_base, nivel) VALUES
(1, 'Professor', 4200.00, 'Analista'),
(2, 'Coordenador Academico', 6800.00, 'Coordenacao'),
(3, 'Assistente Financeiro', 2600.00, 'Operacional');

INSERT IGNORE INTO tb_funcionario (pk_funcionario, fk_cpf, fk_cargo, fk_departamento, nome, email, dt_admissao, salario, regime, status) VALUES
(1, '11111111111', 1, 1, 'Marcos Henrique Silva', 'marcos.silva@sisgesc.edu.br', '2022-02-01', 4500.00, 'CLT', 'ativo'),
(2, '22222222222', 2, 1, 'Ana Paula Costa', 'ana.costa@sisgesc.edu.br', '2021-08-10', 7000.00, 'CLT', 'ativo');

INSERT IGNORE INTO tb_professor (pk_professor, fk_funcionario, titulacao, area_atuacao, reg_conselho) VALUES
(1, 1, 'Mestre', 'Banco de Dados', NULL),
(2, 2, 'Doutor', 'Engenharia de Software', NULL);

-- Academico
INSERT IGNORE INTO tb_aluno (pk_rgm, fk_cpf, nome, telefone, email, status) VALUES
(1001, '33333333333', 'Lucas Almeida', '(11) 90000-0001', 'lucas.almeida@aluno.edu.br', 'ativo'),
(1002, '44444444444', 'Beatriz Santos', '(11) 90000-0002', 'beatriz.santos@aluno.edu.br', 'ativo'),
(1003, '55555555555', 'Rafael Oliveira', '(11) 90000-0003', 'rafael.oliveira@aluno.edu.br', 'ativo');

INSERT IGNORE INTO tb_curso (pk_curso, fk_professor, nome, modalidade, status, carga_horaria, duracao_sem) VALUES
(1, 1, 'Analise e Desenvolvimento de Sistemas', 'EAD', 'ativo', 2000, 5),
(2, 2, 'Sistemas de Informacao', 'Presencial', 'ativo', 3200, 8);

INSERT IGNORE INTO tb_disciplina (pk_disciplina, fk_curso, nome, carga_horaria, periodo) VALUES
(1, 1, 'Banco de Dados I', 80, 2),
(2, 1, 'Modelagem de Dados', 80, 2),
(3, 2, 'Engenharia de Software', 80, 3);

INSERT IGNORE INTO tb_turma (pk_turma, fk_disciplina, fk_professor, codigo_turma, vagas, semestre_ano) VALUES
(1, 1, 1, 'ADS-BD1-2026.1', 40, '2026.1'),
(2, 2, 1, 'ADS-MOD-2026.1', 35, '2026.1'),
(3, 3, 2, 'SI-ES-2026.1', 45, '2026.1');

-- Financeiro: ao inserir contrato ativo, o trigger RN-03 gera mensalidades automaticamente.
INSERT IGNORE INTO tb_contrato (pk_contrato, fk_rgm, fk_curso, dt_inicio, dt_fim, vlr_mensalidade, desconto_pct, status) VALUES
(1, 1001, 1, '2026-02-01', NULL, 650.00, 10.00, 'ativo'),
(2, 1002, 1, '2026-02-01', NULL, 650.00, 0.00, 'ativo'),
(3, 1003, 2, '2026-02-01', NULL, 900.00, 15.00, 'ativo');

-- Matriculas: dependem de contrato ativo e vagas disponiveis.
INSERT IGNORE INTO tb_matricula (pk_matricula, fk_rgm, fk_turma, status, media_final) VALUES
(1, 1001, 1, 'ativa', NULL),
(2, 1001, 2, 'ativa', NULL),
(3, 1002, 1, 'ativa', NULL),
(4, 1003, 3, 'ativa', NULL);

INSERT IGNORE INTO tb_nota (pk_nota, fk_matricula, tipo, valor) VALUES
(1, 1, 'Prova 1', 8.50),
(2, 1, 'Trabalho', 9.00),
(3, 2, 'Prova 1', 7.50),
(4, 3, 'Prova 1', 6.80),
(5, 4, 'Prova 1', 8.00);

INSERT IGNORE INTO tb_falta (pk_falta, fk_matricula, dt_falta, aula_numero, justificada, observacao) VALUES
(1, 1, '2026-03-10', 1, 0, 'Falta sem justificativa'),
(2, 2, '2026-03-11', 2, 1, 'Atestado apresentado'),
(3, 4, '2026-03-12', 1, 0, 'Falta sem justificativa');

-- Pagamentos: usa SELECT para encontrar as mensalidades geradas pelo trigger.
INSERT IGNORE INTO tb_pagamento (fk_mensalidade, dt_pagamento, vlr_pago, forma, cod_transacao, juros, multa)
SELECT m.pk_mensalidade, '2026-02-05', m.vlr_liquido, 'PIX', CONCAT('PIX-', m.fk_contrato, '-', m.mes_ref, '-', m.ano_ref), 0, 0
FROM tb_mensalidade m
WHERE m.mes_ref = 2 AND m.ano_ref = 2026 AND m.fk_contrato IN (1,2,3);

UPDATE tb_mensalidade m
INNER JOIN tb_pagamento p ON p.fk_mensalidade = m.pk_mensalidade
SET m.status = 'pago'
WHERE m.mes_ref = 2 AND m.ano_ref = 2026;
