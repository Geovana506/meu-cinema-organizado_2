# Meu Cinema Organizado

Projeto acadêmico composto por uma API **FastAPI** e um aplicativo **Flutter** para organizar um catálogo pessoal de filmes.

## Estrutura

- `backend/`: API, banco SQLite, SQLAlchemy e autenticação JWT.
- `frontend/`: aplicativo Flutter com cadastro, login e tela inicial autenticada.

## Backend

Requisitos: Python 3.11+ e Poetry.

Na primeira execução:

```bash
cd backend
cp .env.example .env
```

Edite o arquivo `.env` e substitua `SECRET_KEY` por uma chave aleatória longa (pelo menos 32 caracteres). Depois:

```bash
poetry install
poetry run uvicorn app.main:app --reload
```

A documentação interativa estará em http://127.0.0.1:8000/docs.

O SQLite cria o arquivo `meu_cinema.db` dentro de `backend/`. Os quatro filmes que estavam no projeto inicial são inseridos automaticamente quando a tabela está vazia.

## Frontend

Requisitos: Flutter instalado e backend em execução na porta 8000.

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Para Android Emulator, altere `baseUrl` em `lib/repositories/usuario_repository.dart` para `http://10.0.2.2:8000`. Em dispositivo físico, use o IP local do computador na mesma rede.

## Testes

Backend:

```bash
cd backend
poetry run pytest
```

Frontend:

```bash
cd frontend
flutter test
flutter analyze
```

## Autenticação

- Cadastro: `POST /usuarios/`.
- Login: `POST /usuarios/login`; o campo `username` recebe o e-mail.
- Usuário autenticado: `GET /usuarios/eu`.
- As rotas de filmes exigem token Bearer.
- A senha é armazenada como hash bcrypt, nunca em texto puro.
- O JWT expira em 60 minutos.
- Nesta etapa, o token fica em memória no aplicativo; ao fechar o app será necessário entrar novamente.

## Regras do catálogo

A situação `assistido` indica se a pessoa já viu o filme. Ela não representa disponibilidade para empréstimo. O sistema evita cadastrar filmes com o mesmo título e ano.
