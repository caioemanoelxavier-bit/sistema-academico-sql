-- 08_validacao_oltp_olap.sql
-- A soma do OLTP deve bater exatamente com a soma do OLAP.
USE sisgesc;

SELECT
    'OLTP - tb_pagamento' AS origem,
    ROUND(SUM(vlr_pago), 2) AS total_pago
FROM tb_pagamento
UNION ALL
SELECT
    'OLAP - fato_pagamento' AS origem,
    ROUND(SUM(valor_pago), 2) AS total_pago
FROM fato_pagamento;

-- Retorna OK se a diferenca for zero.
SELECT
    CASE
        WHEN ROUND((SELECT SUM(vlr_pago) FROM tb_pagamento), 2) =
             ROUND((SELECT SUM(valor_pago) FROM fato_pagamento), 2)
        THEN 'OK - OLTP e OLAP conferem'
        ELSE 'ERRO - OLTP e OLAP divergentes'
    END AS resultado_validacao;
