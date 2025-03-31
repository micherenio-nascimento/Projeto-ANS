# Projeto ANS - Banco de Dados de Operadoras e Demonstrações Contábeis

Este projeto configura um banco de dados PostgreSQL para armazenar e analisar informações de operadoras de saúde e suas demonstrações contábeis, com base em dados fornecidos em arquivos CSV. Ele utiliza Docker Compose para facilitar a implantação e inclui scripts SQL para criar tabelas e carregar os dados automaticamente.

## Objetivo
O objetivo é criar uma solução para:
- Armazenar informações cadastrais de operadoras de saúde (como razão social, CNPJ, endereço, etc.).
- Registrar demonstrações contábeis trimestrais (como saldos iniciais e finais por conta contábil).
- Permitir consultas analíticas, como identificar operadoras com maiores despesas em categorias específicas (ex.: "EVENTOS/SINISTROS CONHECIDOS OU AVISADOS DE ASSISTÊNCIA A SAÚDE MÉDICO-HOSPITALAR").

## Estrutura do Projeto
```
database/
├── docker-compose.yml        # Configuração do Docker Compose para o PostgreSQL
├── init-scripts/            # Scripts SQL executados na inicialização
│   ├── 01_create_tables.sql  # Criação das tabelas
│   ├── 02_populate_tables.sql # Carregamento dos dados dos CSVs
├── data/                    # Diretório com os arquivos CSV
│   ├── Relatorio_cadop.csv  # Dados cadastrais das operadoras
│   ├── 2023/                # Demonstrações contábeis de 2023
│   │   ├── 1T2023.csv
│   │   ├── 2T2023.csv
│   │   ├── 3T2023.csv
│   │   ├── 4T2023.csv
│   ├── 2024/                # Demonstrações contábeis de 2024
│   │   ├── 1T2024.csv
│   │   ├── 2T2024.csv
│   │   ├── 3T2024.csv
│   │   ├── 4T2024.csv
└── README.md               
```

## Pré-requisitos
- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/install/) instalados na máquina.
- Arquivos CSV no formato especificado (veja a seção "Formato dos Arquivos CSV" abaixo).

## Instalação e Execução
1. **Clone ou configure o diretório do projeto:**
   - Certifique-se de que os arquivos CSV estão no diretório `data/` conforme a estrutura acima.

2. **Suba o container PostgreSQL:**
   No diretório raiz (`database/`), execute:
   ```bash
   docker-compose up -d
   ```
   Isso cria um container PostgreSQL chamado `ans_postgres`, inicializa o banco `ans_db` e carrega os dados dos CSVs.

3. **Verifique os logs (opcional):**
   Para confirmar que os scripts rodaram corretamente:
   ```bash
   docker logs ans_postgres
   ```

4. **Acesse o banco de dados:**
   Conecte-se ao banco para executar consultas:
   ```bash
   docker exec -it ans_postgres psql -U ans_user -d ans_db
   ```

5. **Pare o container (quando necessário):**
   ```bash
   docker-compose down
   ```
   Para remover também os dados persistidos:
   ```bash
   docker-compose down -v
   ```

## Formato dos Arquivos CSV
### `Relatorio_cadop.csv`
Contém informações cadastrais das operadoras:
```
Registro_ANS,CNPJ,Razao_Social,Nome_Fantasia,Modalidade,Logradouro,Numero,Complemento,Bairro,Cidade,UF,CEP,DDD,Telefone,Fax,Endereco_eletronico,Representante,Cargo_Representante,Regiao_de_Comercializacao,Data_Registro_ANS
419761,19541931000125,18 DE JULHO ADMINISTRADORA DE BENEFÍCIOS LTDA,,Administradora de Benefícios,RUA CAPITÃO MEDEIROS DE REZENDE,274,,PRAÇA DA BANDEIRA,Além Paraíba,MG,36660000,32,34624649,,contabilidade@cbnassessoria.com.br,LUIZ HENRIQUE MARENDINO GONÇALVES,SÓCIO ADMINISTRADOR,6,2015-05-19
```

### Arquivos Trimestrais (ex.: `1T2023.csv`)
Contêm demonstrações contábeis:
```
DATA,REG_ANS,CD_CONTA_CONTABIL,DESCRICAO,VL_SALDO_INICIAL,VL_SALDO_FINAL
2023-01-01,360783,12391,OUTROS CRÉDITOS DE OPERAÇÕES DE ASSISTÊNCIA MÉDICO-HOSPITALAR,0,0
```

- Os arquivos devem usar vírgula (`,`) como delimitador e incluir cabeçalho.
- Os dados devem estar consistentes com as tabelas definidas em `01_create_tables.sql`.

## Consultas Analíticas
Aqui estão exemplos de consultas para análise:

### 10 operadoras com maiores despesas no último trimestre (4T2024)
```sql
SELECT 
    o.razao_social,
    o.registro_ans,
    SUM(d.vl_saldo_final) AS total_despesas
FROM 
    demonstracoes_contabeis d
JOIN 
    operadoras o ON d.registro_ans = o.registro_ans
WHERE 
    d.descricao = 'OUTROS CRÉDITOS DE OPERAÇÕES DE ASSISTÊNCIA MÉDICO-HOSPITALAR'
    AND d.data BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY 
    o.razao_social, o.registro_ans
ORDER BY 
    total_despesas DESC
LIMIT 10;
```

### 10 operadoras com maiores despesas no último ano (2024)
```sql
SELECT 
    o.razao_social,
    o.registro_ans,
    SUM(d.vl_saldo_final) AS total_despesas
FROM 
    demonstracoes_contabeis d
JOIN 
    operadoras o ON d.registro_ans = o.registro_ans
WHERE 
    d.descricao = 'OUTROS CRÉDITOS DE OPERAÇÕES DE ASSISTÊNCIA MÉDICO-HOSPITALAR'
    AND d.data BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY 
    o.razao_social, o.registro_ans
ORDER BY 
    total_despesas DESC
LIMIT 10;
```

**Nota:** Ajuste a condição `d.descricao` ou use `d.cd_conta_contabil` conforme os dados reais nos seus CSVs.