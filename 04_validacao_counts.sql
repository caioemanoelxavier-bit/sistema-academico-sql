-- 04_validacao_counts.sql
-- Execute depois da primeira carga e depois da segunda carga.
-- O total de registros precisa permanecer igual.
USE sisgesc;

SELECT 'tb_pessoa' AS tabela, COUNT(*) AS total FROM tb_pessoa
UNION ALL SELECT 'tb_aluno', COUNT(*) FROM tb_aluno
UNION ALL SELECT 'tb_departamento', COUNT(*) FROM tb_departamento
UNION ALL SELECT 'tb_cargo', COUNT(*) FROM tb_cargo
UNION ALL SELECT 'tb_funcionario', COUNT(*) FROM tb_funcionario
UNION ALL SELECT 'tb_professor', COUNT(*) FROM tb_professor
UNION ALL SELECT 'tb_curso', COUNT(*) FROM tb_curso
UNION ALL SELECT 'tb_disciplina', COUNT(*) FROM tb_disciplina
UNION ALL SELECT 'tb_turma', COUNT(*) FROM tb_turma
UNION ALL SELECT 'tb_contrato', COUNT(*) FROM tb_contrato
UNION ALL SELECT 'tb_mensalidade', COUNT(*) FROM tb_mensalidade
UNION ALL SELECT 'tb_pagamento', COUNT(*) FROM tb_pagamento
UNION ALL SELECT 'tb_matricula', COUNT(*) FROM tb_matricula
UNION ALL SELECT 'tb_nota', COUNT(*) FROM tb_nota
UNION ALL SELECT 'tb_falta', COUNT(*) FROM tb_falta;
