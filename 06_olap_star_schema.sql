-- 06_olap_star_schema.sql
USE sisgesc;

CREATE TABLE IF NOT EXISTS dim_aluno (
    sk_aluno INT AUTO_INCREMENT PRIMARY KEY,
    pk_rgm INT NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,
    status VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_curso (
    sk_curso INT AUTO_INCREMENT PRIMARY KEY,
    pk_curso INT NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,
    modalidade VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_unidade (
    sk_unidade INT AUTO_INCREMENT PRIMARY KEY,
    nome_unidade VARCHAR(120) UNIQUE NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    estado CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_tempo (
    sk_tempo INT AUTO_INCREMENT PRIMARY KEY,
    data_ref DATE UNIQUE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    ano INT NOT NULL,
    trimestre INT NOT NULL
);

CREATE TABLE IF NOT EXISTS fato_pagamento (
    sk_fato_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    pk_pagamento_oltp INT NOT NULL UNIQUE,
    sk_aluno INT NOT NULL,
    sk_curso INT NOT NULL,
    sk_unidade INT NOT NULL,
    sk_tempo INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    juros DECIMAL(10,2) NOT NULL DEFAULT 0,
    multa DECIMAL(10,2) NOT NULL DEFAULT 0,
    quantidade_pagamentos INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_fato_aluno FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_fato_curso FOREIGN KEY (sk_curso) REFERENCES dim_curso(sk_curso),
    CONSTRAINT fk_fato_unidade FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    CONSTRAINT fk_fato_tempo FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo)
);
