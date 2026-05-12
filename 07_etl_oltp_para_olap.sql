-- 07_etl_oltp_para_olap.sql
USE sisgesc;

-- Dimensao Unidade: como o OLTP nao possui tabela de unidade, cria-se uma unidade padrao.
INSERT INTO dim_unidade (nome_unidade, cidade, estado)
VALUES ('Unidade Principal', 'Sao Paulo', 'SP')
ON DUPLICATE KEY UPDATE cidade = VALUES(cidade), estado = VALUES(estado);

-- Dimensao Aluno
INSERT INTO dim_aluno (pk_rgm, nome, status)
SELECT a.pk_rgm, a.nome, a.status
FROM tb_aluno a
ON DUPLICATE KEY UPDATE nome = VALUES(nome), status = VALUES(status);

-- Dimensao Curso
INSERT INTO dim_curso (pk_curso, nome, modalidade)
SELECT c.pk_curso, c.nome, c.modalidade
FROM tb_curso c
ON DUPLICATE KEY UPDATE nome = VALUES(nome), modalidade = VALUES(modalidade);

-- Dimensao Tempo com base nas datas de pagamento.
INSERT INTO dim_tempo (data_ref, dia, mes, ano, trimestre)
SELECT DISTINCT
    p.dt_pagamento AS data_ref,
    DAY(p.dt_pagamento) AS dia,
    MONTH(p.dt_pagamento) AS mes,
    YEAR(p.dt_pagamento) AS ano,
    QUARTER(p.dt_pagamento) AS trimestre
FROM tb_pagamento p
ON DUPLICATE KEY UPDATE
    dia = VALUES(dia),
    mes = VALUES(mes),
    ano = VALUES(ano),
    trimestre = VALUES(trimestre);

-- Tabela Fato de Pagamentos
INSERT INTO fato_pagamento (
    pk_pagamento_oltp,
    sk_aluno,
    sk_curso,
    sk_unidade,
    sk_tempo,
    valor_pago,
    juros,
    multa,
    quantidade_pagamentos
)
SELECT
    p.pk_pagamento,
    da.sk_aluno,
    dc.sk_curso,
    du.sk_unidade,
    dt.sk_tempo,
    p.vlr_pago,
    p.juros,
    p.multa,
    1
FROM tb_pagamento p
INNER JOIN tb_mensalidade m ON m.pk_mensalidade = p.fk_mensalidade
INNER JOIN tb_contrato co ON co.pk_contrato = m.fk_contrato
INNER JOIN dim_aluno da ON da.pk_rgm = co.fk_rgm
INNER JOIN dim_curso dc ON dc.pk_curso = co.fk_curso
INNER JOIN dim_unidade du ON du.nome_unidade = 'Unidade Principal'
INNER JOIN dim_tempo dt ON dt.data_ref = p.dt_pagamento
ON DUPLICATE KEY UPDATE
    sk_aluno = VALUES(sk_aluno),
    sk_curso = VALUES(sk_curso),
    sk_unidade = VALUES(sk_unidade),
    sk_tempo = VALUES(sk_tempo),
    valor_pago = VALUES(valor_pago),
    juros = VALUES(juros),
    multa = VALUES(multa);
