# SQL-db-specialist
Repository created for my projects from the SQL Database Specialist course from Dio platform.

---

PROJETOS

1. Ecommerce (Módulo 2 e 3):
   
  Este projeto consiste em um banco de dados relacional para um sistema de e-commerce, desenvolvido em MySQL, que gerencia todo o fluxo operacional de uma loja virtual. O modelo contempla desde o cadastro de clientes (Pessoa Física e Pessoa Jurídica) até o controle de pedidos, estoque, fornecedores, entregas e pagamentos.

🗂️ Estrutura do Banco de Dados
O banco de dados é composto pelas seguintes entidades principais:

🔹Clientes PF/PJ: Cadastro segregado por tipo de cliente

🔹Pedidos: Registro de transações com status e frete

🔹Produtos: Catálogo com nome, categoria e valor

🔹Estoque: Controle de quantidades disponíveis

🔹Fornecedores: Cadastro de empresas fornecedoras

🔹Terceiros Vendedores: Vendedores externos parceiros

🔹Entregas: Rastreamento e status de envio

🔹Pagamentos: Múltiplas formas de pagamento com data

🔍 Explicação das Cláusulas SQL Utilizadas

✅ WHERE: Filtra registros específicos com base em condições.
✅ ORDER BY: Ordena os resultados em ordem crescente (ASC) ou decrescente (DESC).
✅ GROUP BY: Agrupa registros com valores idênticos para funções de agregação.
✅ HAVING: Filtra grupos após a aplicação do GROUP BY (diferente do WHERE, que filtra antes).
✅ JOINs (INNER, LEFT, RIGHT): Combina registros de duas ou mais tabelas:

  INNER JOIN: Retorna apenas registros com correspondência
  LEFT JOIN: Retorna todos os registros da tabela esquerda

✅ Atributos Derivados: Campos calculados durante a consulta usando expressões.
✅ CASE (Estrutura Condicional): Cria categorizações ou classificações condicionais.
✅ Subconsultas: Consultas aninhadas dentro de outra consulta.

✅ Funções de Agregação: 

COUNT(): Conta registros
SUM(): Soma valores
AVG(): Calcula média
MAX()/MIN(): Valor máximo/mínimo


<img width="978" height="995" alt="e-commerce" src="https://github.com/user-attachments/assets/ce93ee00-0f7b-4a1a-8efe-5c47e6bd7bf3" />


2. Oficina mecânica (Módulo 2 - Modelo de Dados Relacionais):

<img width="982" height="875" alt="Oficina" src="https://github.com/user-attachments/assets/58b08f93-3f01-45aa-8839-99f946528fee" />
