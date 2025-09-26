# Sistema de Gestão de Granjas – Avaliação Delphi

**Flip Cursos e Engenharia**  
Rua Assis Brasil, n° 448, Vila Isabel, Pato Branco-PR  

**Avaliação Prática – Desenvolvedor Delphi**  

---

## Objetivo

Este projeto foi desenvolvido como parte da avaliação prática para o cargo de desenvolvedor Delphi. O objetivo é demonstrar capacidade em:

- Lógica de programação e validação de regras de negócio  
- Programação orientada a objetos (POO)  
- Manipulação de banco de dados PostgreSQL/Oracle via SQL, PL/SQL e Delphi  
- Desenvolvimento de interfaces gráficas e usabilidade para aplicações desktop  

---

## Cenário

O sistema simula um módulo de **gestão de granjas**, com foco em **controle de pesagem e mortalidade de aves**.  

O usuário pode:

1. Visualizar lotes de aves cadastrados  
2. Registrar pesagens  
3. Registrar mortalidades  
4. Observar indicadores de saúde dos lotes (cores no DBGrid indicando mortalidade acumulada)  

---

## Estrutura do Banco de Dados

O projeto utiliza PostgreSQL (adaptado do Oracle) com as seguintes tabelas:

### TAB_LOTE_AVES
| Campo               | Tipo            | Observação |
|--------------------|----------------|------------|
| ID_LOTE             | integer (PK)   | Identificador único do lote |
| DESCRICAO           | varchar(100)   | Descrição do lote |
| DATA_ENTRADA        | date           | Data de entrada do lote |
| QUANTIDADE_INICIAL  | numeric        | Quantidade inicial de aves |

### TAB_PESAGEM
| Campo               | Tipo           | Observação |
|--------------------|---------------|------------|
| ID_PESAGEM          | integer (PK)  | Identificador da pesagem |
| ID_LOTE_FK          | integer (FK)  | Referência ao lote |
| DATA_PESAGEM        | date          | Data da pesagem |
| PESO_MEDIO          | numeric(10,2) | Peso médio registrado |
| QUANTIDADE_PESADA   | numeric       | Quantidade de aves pesadas |

### TAB_MORTALIDADE
| Campo               | Tipo           | Observação |
|--------------------|---------------|------------|
| ID_MORTALIDADE      | integer (PK)  | Identificador da mortalidade |
| ID_LOTE_FK          | integer (FK)  | Referência ao lote |
| DATA_MORTALIDADE    | date          | Data da ocorrência |
| QUANTIDADE_MORTA    | numeric       | Quantidade de aves mortas |
| OBSERVACAO          | varchar(255)  | Observação adicional |

---

## Funcionalidades da Aplicação Delphi

### Tela Principal
- Lista os lotes cadastrados em um **DBGrid**  
- Exibe percentual de mortalidade acumulada com cores:
  - **Verde**: < 6%  
  - **Amarelo**: 6% a 10%  
  - **Vermelho**: > 10%  

### Tela de Pesagem
- Permite lançar:
  - Data da pesagem  
  - Peso médio  
  - Quantidade de aves pesadas  
- **Validação:** a quantidade lançada não pode ultrapassar a quantidade inicial do lote  

### Tela de Mortalidade
- Permite lançar:
  - Data da mortalidade  
  - Quantidade de aves mortas  
  - Observações  
- **Validação:** a soma das mortalidades não pode ultrapassar a quantidade inicial do lote  

---

## Lógica de Programação

- Classes **POO** para representar entidades: `TLote`, `TPesagem`, `TMortalidade`  
- Encapsulamento dos dados e métodos de manipulação  
- Validações de regras de negócio implementadas no Delphi antes da inserção no banco  
- Indicador visual de saúde do lote atualizado automaticamente no DBGrid (`DBGrid1DrawColumnCell`)  

---

## SQL e Stored Procedures

- **`fn_inserir_pesagem`**: insere uma pesagem e valida quantidade máxima permitida  
- **`fn_inserir_mortalidade`**: insere uma mortalidade, calcula percentual acumulado e retorna valor para o Delphi  
- A aplicação se comunica com o banco através dessas funções, garantindo consistência de dados  

---

## Requisitos para Executar

1. **PostgreSQL 16.x** (ou compatível)  
2. **Delphi ou Lazarus** (Free Pascal, compatível com Lazarus IDE)  
3. Script SQL disponível no repositório para criação do banco e inserção de dados de teste (`dump.sql`)  

---

## Passo a Passo para Executar

1. **Criar o banco e tabelas**
   - Abrir o PostgreSQL  
   - Executar os scripts `Criacao_Tabelas.sql` e `insercao_dados.sql` para criar tabelas, sequências e funções  

2. **Abrir o projeto no Lazarus**
   - Abrir `Project.lpi` ou `Unit1.lpi`  
   - Certificar-se que a biblioteca `SQLDB` e `PQConnection` estão disponíveis  

3. **Configurar conexão com o banco**
   - Editar `PQConnection1` na tela principal:  
     - Host: `localhost`  
     - Database: `nome_do_banco`  
     - User: `seu_usuario`  
     - Password: `sua_senha`  
   - Conectar para testar  

4. **Executar a aplicação**
   - Pressionar **Run**  
   - Testar lançamento de pesagens e mortalidades  
   - Observar cores do DBGrid conforme percentual de mortalidade  

---

## Observações

- Todas as validações de quantidade (pesagem e mortalidade) estão implementadas  
- Indicador de saúde do lote atualizado automaticamente  
- Código estruturado com POO para fácil manutenção e extensão  
