# 📦 Controle de Estoque (Flask + Flutter)
Este é um projeto de exemplo de um aplicativo para controle de estoque, com um backend leve em Flask e um frontend multiplataforma em Flutter.

## 📷 Imagens

<img src='https://i.imgur.com/abViCI0.png'>  <img src='https://i.imgur.com/b0EkKHI.png'>  <img src='https://i.imgur.com/JWlYvNy.png'>  <img src='https://i.imgur.com/4XAs27y.png'>  <img src='https://i.imgur.com/VlEc1FI.png'>

## 🚀 Funcionalidades
O aplicativo oferece as seguintes funcionalidades principais:
- **Cadastro de Produtos:** Adição de novos produtos com código de barras, descrição e quantidade inicial.
- **Leitor de Código de Barras:** Utilização da câmera do celular para ler o código de barras e preencher o campo de busca ou cadastro.
- **Gestão de Estoque:** Alteração da quantidade de produtos existentes, com opções de adição, remoção ou ajuste.
- **Busca Inteligente:** Filtragem de produtos por descrição ou código de barras na tela de listagem.
- **Histórico de Movimentos:** Visualização de todas as entradas e saídas de produtos, com data e hora.
- **Exclusão de Produtos:** Remoção de produtos e seus movimentos associados do banco de dados.
- **Configuração de Servidor:** Armazenamento persistente do endereço do servidor, permitindo que o aplicativo se conecte a diferentes ambientes.

## 💻 Tecnologias Utilizadas
**Backend (API REST)**
- **Python:** Linguagem de programação principal.
- **Flask:** Micro-framework web para criação dos endpoints da API.
- **SQLite3:** Banco de dados leve e embutido para armazenar as informações.
- **CORS:** Para permitir o acesso do aplicativo Flutter à API.

**Frontend (Aplicativo Móvel)**
- **Flutter:** Framework para o desenvolvimento multiplataforma.
- **Dart:** Linguagem de programação do Flutter.
- ```http```: Pacote para fazer requisições HTTP à API.
- ```shared_preferences```: Para savar a URL do servidor localmente.
- ```mobile_scanner```: Pacote para a leitura de códigos de barras.

## ⚙️ Como Configurar e Rodar o Projeto
Siga os passos abaixo para colocar a aplicação em funcionamento.

1. **Configuração do Backend**
   1. **Clone o Repositório:**
      ```git clone https://github.com/srkrash/Controle-Estoque/```
   2. **Crie e ative o Ambiente Virtual(**```venv```**):**
      ```
      python -m venv venv
      # No Windows:
      venv\Scripts\activate
      # No macOS/Linux:
      source venv/bin/activate
      ```
   3. **Instale as Dependências do Python:**
     ```pip install -r requirements.txt```
   4. **Execute a Aplicação Flask:**
     ```python api.py```

2. **Configuração do Frontend (Flutter)**
   1. **Instale o Flutter SDK:** Siga as instruções no <a href=https://docs.flutter.dev/get-started/install>site oficial do Flutter</a>.
   2. **Obtenha as Dependências do Projeto:**
        ```
        cd estoque
        flutter pub get
        ```
   3. **Execute o Aplicativo Flutter:**
      ```flutter run```

## **📄 Licença**
Este projeto está sob licença <a href='#'>MIT</a>
