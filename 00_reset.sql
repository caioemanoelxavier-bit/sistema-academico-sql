-- 00_reset.sql
-- Limpa o ambiente para uma nova instalacao.
-- ATENCAO: execute apenas em ambiente de testes/apresentacao.

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS fato_pagamento;
DROP TABLE IF EXISTS dim_tempo;
DROP TABLE IF EXISTS dim_aluno;
DROP TABLE IF EXISTS dim_curso;
DROP TABLE IF EXISTS dim_unidade;

DROP TABLE IF EXISTS tb_falta;
DROP TABLE IF EXISTS tb_nota;
DROP TABLE IF EXISTS tb_matricula;
DROP TABLE IF EXISTS tb_pagamento;
DROP TABLE IF EXISTS tb_mensalidade;
DROP TABLE IF EXISTS tb_contrato;
DROP TABLE IF EXISTS tb_turma;
DROP TABLE IF EXISTS tb_disciplina;
DROP TABLE IF EXISTS tb_curso;
DROP TABLE IF EXISTS tb_professor;
DROP TABLE IF EXISTS tb_funcionario;
DROP TABLE IF EXISTS tb_cargo;
DROP TABLE IF EXISTS tb_departamento;
DROP TABLE IF EXISTS tb_aluno;
DROP TABLE IF EXISTS tb_pessoa;

SET FOREIGN_KEY_CHECKS = 1;
