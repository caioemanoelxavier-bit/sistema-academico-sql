-- 09_indices_performance.sql
USE sisgesc;

CREATE INDEX idx_aluno_email ON tb_aluno(email);
CREATE INDEX idx_matricula_rgm ON tb_matricula(fk_rgm);
CREATE INDEX idx_matricula_turma ON tb_matricula(fk_turma);
CREATE INDEX idx_contrato_rgm_curso ON tb_contrato(fk_rgm, fk_curso);
CREATE INDEX idx_mensalidade_status ON tb_mensalidade(status);
CREATE INDEX idx_pagamento_mensalidade ON tb_pagamento(fk_mensalidade);
CREATE INDEX idx_pagamento_data ON tb_pagamento(dt_pagamento);
CREATE INDEX idx_fato_pagamento_tempo ON fato_pagamento(sk_tempo);
CREATE INDEX idx_fato_pagamento_aluno ON fato_pagamento(sk_aluno);

-- Demonstracao com EXPLAIN.
EXPLAIN
SELECT
    a.nome,
    COUNT(m.pk_matricula) AS total_matriculas
FROM tb_aluno a
INNER JOIN tb_matricula m ON m.fk_rgm = a.pk_rgm
GROUP BY a.nome;

EXPLAIN
SELECT
    a.nome,
    SUM(p.vlr_pago) AS total_pago
FROM tb_pagamento p
INNER JOIN tb_mensalidade me ON me.pk_mensalidade = p.fk_mensalidade
INNER JOIN tb_contrato co ON co.pk_contrato = me.fk_contrato
INNER JOIN tb_aluno a ON a.pk_rgm = co.fk_rgm
GROUP BY a.nome;
