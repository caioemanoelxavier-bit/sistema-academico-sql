-- run_all.sql
-- Execute este arquivo no MySQL Workbench ou terminal MySQL.
-- Ajuste os caminhos se estiver executando fora da raiz do repositorio.

SOURCE scripts/00_reset.sql;
SOURCE scripts/01_ddl_oltp.sql;
SOURCE scripts/02_triggers_regras_negocio.sql;
SOURCE scripts/03_dml_carga_dados_idempotente.sql;
SOURCE scripts/04_validacao_counts.sql;

-- Reexecutar DML para provar idempotencia:
SOURCE scripts/03_dml_carga_dados_idempotente.sql;
SOURCE scripts/04_validacao_counts.sql;

SOURCE scripts/05_consultas_oltp.sql;
SOURCE scripts/06_olap_star_schema.sql;
SOURCE scripts/07_etl_oltp_para_olap.sql;
SOURCE scripts/08_validacao_oltp_olap.sql;
SOURCE scripts/09_indices_performance.sql;
