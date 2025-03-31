CREATE TABLE IF NOT EXISTS operadoras (
    id SERIAL PRIMARY KEY,
    registro_ans VARCHAR(20) UNIQUE NOT NULL,
    cnpj VARCHAR(20) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    modalidade VARCHAR(100),
    logradouro VARCHAR(255),
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf VARCHAR(2),
    cep VARCHAR(10),
    ddd VARCHAR(3),
    telefone VARCHAR(15),
    fax VARCHAR(15),
    endereco_eletronico VARCHAR(255),
    representante VARCHAR(255),
    cargo_representante VARCHAR(100),
    regiao_comercializacao INT,
    data_registro DATE
);

CREATE TABLE IF NOT EXISTS demonstracoes_contabeis (
    id SERIAL PRIMARY KEY,
    registro_ans VARCHAR(20) REFERENCES operadoras(registro_ans),
    data DATE NOT NULL, 
    cd_conta_contabil VARCHAR(20) NOT NULL,
    descricao VARCHAR(255),
    vl_saldo_inicial NUMERIC(18,2) NOT NULL, 
    vl_saldo_final NUMERIC(18,2) NOT NULL,
    CONSTRAINT unique_demo UNIQUE (registro_ans, data, cd_conta_contabil) 
);

CREATE TEMP TABLE temp_demonstracoes (
    data DATE,
    registro_ans VARCHAR(20),
    cd_conta_contabil VARCHAR(20),
    descricao VARCHAR(255),
    vl_saldo_inicial NUMERIC(18,2),
    vl_saldo_final NUMERIC(18,2)
);