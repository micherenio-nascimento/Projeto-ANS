CREATE OR REPLACE FUNCTION load_demonstracoes_from_csv(file_path TEXT) RETURNS VOID AS $$
BEGIN

    EXECUTE format('
        COPY temp_demonstracoes (
            data, registro_ans, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final
        )
        FROM %L
        DELIMITER '',''
        CSV HEADER;
    ', file_path);

    INSERT INTO demonstracoes_contabeis (
        registro_ans, data, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final
    )
    SELECT 
        registro_ans, data, cd_conta_contabil, descricao, vl_saldo_inicial, vl_saldo_final
    FROM temp_demonstracoes
    ON CONFLICT ON CONSTRAINT unique_demo DO NOTHING;

    TRUNCATE temp_demonstracoes;
END;
$$ LANGUAGE plpgsql;

COPY operadoras (
    registro_ans, cnpj, razao_social, nome_fantasia, modalidade, logradouro, numero, 
    complemento, bairro, cidade, uf, cep, ddd, telefone, fax, endereco_eletronico, 
    representante, cargo_representante, regiao_comercializacao, data_registro
) 
FROM '/data/Relatorio_cadop.csv' 
DELIMITER ',' 
CSV HEADER;

DO $$
BEGIN

    PERFORM load_demonstracoes_from_csv('/data/2023/1T2023.csv');
    PERFORM load_demonstracoes_from_csv('/data/2023/2T2023.csv');
    PERFORM load_demonstracoes_from_csv('/data/2023/3T2023.csv');
    PERFORM load_demonstracoes_from_csv('/data/2023/4T2023.csv');

    PERFORM load_demonstracoes_from_csv('/data/2024/1T2024.csv');
    PERFORM load_demonstracoes_from_csv('/data/2024/2T2024.csv');
    PERFORM load_demonstracoes_from_csv('/data/2024/3T2024.csv');
    PERFORM load_demonstracoes_from_csv('/data/2024/4T2024.csv');
END;
$$;