-- 05_consultas_oltp.sql
USE sisgesc;

-- Consulta 1: alunos, cursos, disciplinas e status da matricula.
SELECT
    a.pk_rgm,
    a.nome AS aluno,
    c.nome AS curso,
    d.nome AS disciplina,
    t.codigo_turma,
    m.status AS status_matricula
FROM tb_matricula m
INNER JOIN tb_aluno a ON a.pk_rgm = m.fk_rgm
INNER JOIN tb_turma t ON t.pk_turma = m.fk_turma
INNER JOIN tb_disciplina d ON d.pk_disciplina = t.fk_disciplina
INNER JOIN tb_curso c ON c.pk_curso = d.fk_curso
ORDER BY a.nome, d.nome;

-- Consulta 2: total pago por aluno.
SELECT
    a.nome AS aluno,
    SUM(p.vlr_pago) AS total_pago
FROM tb_pagamento p
INNER JOIN tb_mensalidade me ON me.pk_mensalidade = p.fk_mensalidade
INNER JOIN tb_contrato co ON co.pk_contrato = me.fk_contrato
INNER JOIN tb_aluno a ON a.pk_rgm = co.fk_rgm
GROUP BY a.nome
ORDER BY total_pago DESC;

-- Consulta 3: subselect correlacionado com media de notas por aluno.
SELECT
    a.pk_rgm,
    a.nome,
    (
        SELECT ROUND(AVG(n.valor), 2)
        FROM tb_matricula m
        INNER JOIN tb_nota n ON n.fk_matricula = m.pk_matricula
        WHERE m.fk_rgm = a.pk_rgm
    ) AS media_geral
FROM tb_aluno a;

-- Consulta 4: alunos com mensalidade pendente.
SELECT
    a.nome AS aluno,
    COUNT(me.pk_mensalidade) AS mensalidades_pendentes,
    SUM(me.vlr_liquido) AS valor_pendente
FROM tb_mensalidade me
INNER JOIN tb_contrato co ON co.pk_contrato = me.fk_contrato
INNER JOIN tb_aluno a ON a.pk_rgm = co.fk_rgm
WHERE me.status = 'pendente'
GROUP BY a.nome
HAVING COUNT(me.pk_mensalidade) > 0;
