-- 01_ddl_oltp.sql
-- Banco: MySQL 8+
-- Padrao: snake_case, PK com pk_, FK com fk_, campos monetarios DECIMAL(10,2).

CREATE DATABASE IF NOT EXISTS sisgesc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sisgesc;

-- =========================================================
-- MODULO BASE / PESSOA
-- =========================================================
CREATE TABLE IF NOT EXISTS tb_pessoa (
    pk_cpf CHAR(11) PRIMARY KEY,
    rg VARCHAR(20) UNIQUE NOT NULL,
    dt_nascimento DATE NOT NULL,
    genero ENUM('M', 'F', 'Outro', 'N/I') NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- MODULO RH
-- =========================================================
CREATE TABLE IF NOT EXISTS tb_departamento (
    pk_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    descricao VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS tb_cargo (
    pk_cargo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL,
    nivel ENUM('Operacional', 'Tecnico', 'Analista', 'Coordenacao', 'Gerencia') NOT NULL DEFAULT 'Operacional',
    CONSTRAINT chk_cargo_salario_base CHECK (salario_base > 0)
);

CREATE TABLE IF NOT EXISTS tb_funcionario (
    pk_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    fk_cpf CHAR(11) UNIQUE NOT NULL,
    fk_cargo INT NOT NULL,
    fk_departamento INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    dt_admissao DATE NOT NULL,
    dt_demissao DATE NULL,
    salario DECIMAL(10,2) NOT NULL,
    regime ENUM('CLT', 'PJ', 'Estagio', 'Temporario') NOT NULL DEFAULT 'CLT',
    status ENUM('ativo', 'inativo', 'afastado', 'demitido') NOT NULL DEFAULT 'ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_funcionario_pessoa FOREIGN KEY (fk_cpf) REFERENCES tb_pessoa(pk_cpf),
    CONSTRAINT fk_funcionario_cargo FOREIGN KEY (fk_cargo) REFERENCES tb_cargo(pk_cargo),
    CONSTRAINT fk_funcionario_departamento FOREIGN KEY (fk_departamento) REFERENCES tb_departamento(pk_departamento),
    CONSTRAINT chk_funcionario_salario CHECK (salario > 0),
    CONSTRAINT chk_funcionario_demissao CHECK (dt_demissao IS NULL OR dt_demissao >= dt_admissao)
);

CREATE TABLE IF NOT EXISTS tb_professor (
    pk_professor INT AUTO_INCREMENT PRIMARY KEY,
    fk_funcionario INT UNIQUE NOT NULL,
    titulacao ENUM('Graduado', 'Especialista', 'Mestre', 'Doutor') NOT NULL DEFAULT 'Graduado',
    area_atuacao VARCHAR(100) NOT NULL,
    reg_conselho VARCHAR(50) NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_professor_funcionario FOREIGN KEY (fk_funcionario) REFERENCES tb_funcionario(pk_funcionario) ON DELETE RESTRICT
);

-- =========================================================
-- MODULO ACADEMICO
-- =========================================================
CREATE TABLE IF NOT EXISTS tb_aluno (
    pk_rgm INT AUTO_INCREMENT PRIMARY KEY,
    fk_cpf CHAR(11) UNIQUE NOT NULL,
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    status ENUM('ativo', 'trancado', 'formado', 'evadido') NOT NULL DEFAULT 'ativo',
    dt_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_aluno_pessoa FOREIGN KEY (fk_cpf) REFERENCES tb_pessoa(pk_cpf)
);

CREATE TABLE IF NOT EXISTS tb_curso (
    pk_curso INT AUTO_INCREMENT PRIMARY KEY,
    fk_professor INT NULL,
    nome VARCHAR(150) UNIQUE NOT NULL,
    modalidade ENUM('Presencial', 'EAD', 'Semi presencial') NOT NULL,
    status ENUM('ativo', 'suspenso', 'encerrado') NOT NULL DEFAULT 'ativo',
    carga_horaria INT NOT NULL,
    duracao_sem TINYINT NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_curso_professor FOREIGN KEY (fk_professor) REFERENCES tb_professor(pk_professor),
    CONSTRAINT chk_curso_carga CHECK (carga_horaria > 0),
    CONSTRAINT chk_curso_duracao CHECK (duracao_sem BETWEEN 1 AND 20)
);

CREATE TABLE IF NOT EXISTS tb_disciplina (
    pk_disciplina INT AUTO_INCREMENT PRIMARY KEY,
    fk_curso INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    carga_horaria INT NOT NULL,
    periodo TINYINT NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_disciplina_curso FOREIGN KEY (fk_curso) REFERENCES tb_curso(pk_curso),
    CONSTRAINT unq_disciplina_curso UNIQUE (fk_curso, nome),
    CONSTRAINT chk_disciplina_carga CHECK (carga_horaria > 0),
    CONSTRAINT chk_disciplina_periodo CHECK (periodo BETWEEN 1 AND 10)
);

CREATE TABLE IF NOT EXISTS tb_turma (
    pk_turma INT AUTO_INCREMENT PRIMARY KEY,
    fk_disciplina INT NOT NULL,
    fk_professor INT NOT NULL,
    codigo_turma VARCHAR(50) UNIQUE NOT NULL,
    vagas INT NOT NULL,
    semestre_ano VARCHAR(6) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_turma_vagas CHECK (vagas > 0),
    CONSTRAINT fk_turma_disciplina FOREIGN KEY (fk_disciplina) REFERENCES tb_disciplina(pk_disciplina),
    CONSTRAINT fk_turma_professor FOREIGN KEY (fk_professor) REFERENCES tb_professor(pk_professor)
);

-- =========================================================
-- MODULO FINANCEIRO
-- =========================================================
CREATE TABLE IF NOT EXISTS tb_contrato (
    pk_contrato INT AUTO_INCREMENT PRIMARY KEY,
    fk_rgm INT NOT NULL,
    fk_curso INT NOT NULL,
    dt_inicio DATE NOT NULL,
    dt_fim DATE NULL,
    vlr_mensalidade DECIMAL(10,2) NOT NULL,
    desconto_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    status ENUM('ativo', 'suspenso', 'encerrado', 'cancelado') NOT NULL DEFAULT 'ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_contrato_aluno FOREIGN KEY (fk_rgm) REFERENCES tb_aluno(pk_rgm),
    CONSTRAINT fk_contrato_curso FOREIGN KEY (fk_curso) REFERENCES tb_curso(pk_curso),
    CONSTRAINT unq_contrato_aluno_curso_inicio UNIQUE (fk_rgm, fk_curso, dt_inicio),
    CONSTRAINT chk_contrato_valor CHECK (vlr_mensalidade > 0),
    CONSTRAINT chk_contrato_desconto CHECK (desconto_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_contrato_datas CHECK (dt_fim IS NULL OR dt_fim > dt_inicio)
);

CREATE TABLE IF NOT EXISTS tb_mensalidade (
    pk_mensalidade INT AUTO_INCREMENT PRIMARY KEY,
    fk_contrato INT NOT NULL,
    mes_ref TINYINT NOT NULL,
    ano_ref YEAR NOT NULL,
    vlr_bruto DECIMAL(10,2) NOT NULL,
    vlr_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
    vlr_liquido DECIMAL(10,2) NOT NULL,
    dt_vencimento DATE NOT NULL,
    status ENUM('pendente', 'pago', 'atrasado', 'isento', 'cancelado') NOT NULL DEFAULT 'pendente',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_mensalidade_contrato FOREIGN KEY (fk_contrato) REFERENCES tb_contrato(pk_contrato),
    CONSTRAINT unq_mensalidade_contrato_mes_ano UNIQUE (fk_contrato, mes_ref, ano_ref),
    CONSTRAINT chk_mensalidade_mes CHECK (mes_ref BETWEEN 1 AND 12),
    CONSTRAINT chk_mensalidade_bruto CHECK (vlr_bruto > 0),
    CONSTRAINT chk_mensalidade_desconto CHECK (vlr_desconto >= 0),
    CONSTRAINT chk_mensalidade_liquido CHECK (vlr_liquido >= 0)
);

CREATE TABLE IF NOT EXISTS tb_pagamento (
    pk_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    fk_mensalidade INT NOT NULL,
    dt_pagamento DATE NOT NULL,
    vlr_pago DECIMAL(10,2) NOT NULL,
    forma ENUM('PIX', 'Boleto', 'Cartao', 'Dinheiro', 'Transferencia') NOT NULL,
    cod_transacao VARCHAR(100) UNIQUE NULL,
    juros DECIMAL(10,2) NOT NULL DEFAULT 0,
    multa DECIMAL(10,2) NOT NULL DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagamento_mensalidade FOREIGN KEY (fk_mensalidade) REFERENCES tb_mensalidade(pk_mensalidade),
    CONSTRAINT chk_pagamento_valor CHECK (vlr_pago > 0),
    CONSTRAINT chk_pagamento_juros CHECK (juros >= 0),
    CONSTRAINT chk_pagamento_multa CHECK (multa >= 0)
);

-- =========================================================
-- VOLTA AO MODULO ACADEMICO - depende de turma e contrato
-- =========================================================
CREATE TABLE IF NOT EXISTS tb_matricula (
    pk_matricula INT AUTO_INCREMENT PRIMARY KEY,
    fk_rgm INT NOT NULL,
    fk_turma INT NOT NULL,
    status ENUM('ativa', 'reprovada', 'aprovada', 'cancelada') NOT NULL DEFAULT 'ativa',
    media_final DECIMAL(4,2) NULL,
    dt_matricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_matricula_media CHECK (media_final IS NULL OR (media_final >= 0.00 AND media_final <= 10.00)),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (fk_rgm) REFERENCES tb_aluno(pk_rgm),
    CONSTRAINT fk_matricula_turma FOREIGN KEY (fk_turma) REFERENCES tb_turma(pk_turma),
    CONSTRAINT unq_matricula_aluno_turma UNIQUE (fk_rgm, fk_turma)
);

CREATE TABLE IF NOT EXISTS tb_nota (
    pk_nota INT AUTO_INCREMENT PRIMARY KEY,
    fk_matricula INT NOT NULL,
    tipo ENUM('Prova 1', 'Prova 2', 'Prova 3', 'Trabalho', 'Final') NOT NULL,
    valor DECIMAL(4,2) NOT NULL,
    dt_lancamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nota_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula(pk_matricula),
    CONSTRAINT unq_nota_matricula_tipo UNIQUE (fk_matricula, tipo),
    CONSTRAINT chk_nota_valor CHECK (valor BETWEEN 0.00 AND 10.00)
);

CREATE TABLE IF NOT EXISTS tb_falta (
    pk_falta INT AUTO_INCREMENT PRIMARY KEY,
    fk_matricula INT NOT NULL,
    dt_falta DATE NOT NULL,
    aula_numero TINYINT NOT NULL,
    justificada TINYINT(1) NOT NULL DEFAULT 0,
    observacao VARCHAR(255) NULL,
    CONSTRAINT fk_falta_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula(pk_matricula),
    CONSTRAINT unq_falta_matricula_data_aula UNIQUE (fk_matricula, dt_falta, aula_numero),
    CONSTRAINT chk_falta_aula CHECK (aula_numero >= 1),
    CONSTRAINT chk_falta_justificada CHECK (justificada IN (0,1))
);
