# Meu Cinema Organizado

Aplicação acadêmica para organizar um catálogo pessoal de filmes. O repositório reúne a API FastAPI, o aplicativo Flutter desenvolvido nos encontros da disciplina e o protótipo visual original criado no Lovable.

## Visão geral

O **Lovable** é preservado como protótipo de referência. O **Flutter** continua sendo o frontend principal em desenvolvimento e consome a API FastAPI. As telas Flutter serão alinhadas gradualmente à experiência visual e aos fluxos definidos no protótipo, sem substituir a implementação Flutter.

## Estrutura

- `backend/`: API FastAPI, SQLite/SQLAlchemy, autenticação JWT e endpoints do catálogo.
- `frontend/`: aplicativo Flutter, autenticação, sessão persistente, listagem, detalhes e CRUD.
- `prototipo-lovable/`: código original React/TypeScript, preservado como referência visual e funcional.
- `docs/`: documentação complementar e materiais dos encontros.

## Tecnologias

| Camada | Tecnologias |
|---|---|
| API | Python, FastAPI, SQLAlchemy, SQLite, JWT, bcrypt |
| Aplicativo | Flutter, Dart, Provider, shared_preferences |
| Protótipo | React, TypeScript, Vite, Tailwind CSS, shadcn/ui |

## Funcionalidades implementadas no Flutter

- Cadastro e login de usuários.
- Autenticação JWT e recuperação de sessão persistente.
- Perfil e navegação protegida.
- Listagem de filmes com estados de carregamento, erro e lista vazia.
- Detalhamento de filme.
- Cadastro, edição e exclusão com confirmação.
- Testes automatizados de telas, serviços, repositórios, sessão e CRUD.

> **Escopo atual da API:** as rotas de filmes exigem autenticação, mas o modelo `Filme` ainda não está relacionado a um usuário. Neste estágio, o catálogo é compartilhado entre as contas autenticadas.

## Histórico dos encontros

| Encontro | Conteúdo e entregas |
|---|---|
| 04 | Estrutura inicial do projeto e organização do backend/API. |
| 05 | Configuração das dependências e execução da API FastAPI. |
| 06 | Modelagem e persistência com SQLAlchemy e SQLite. |
| 07 | Endpoints de filmes e documentação interativa da API. |
| 08 | Organização das camadas e preparação da API para o aplicativo. |
| 09 | Integração do Flutter com a API e fluxos de autenticação. |
| 10 | Cadastro, JWT e sessão persistente com armazenamento local. |
| 11 | Listagem e detalhe de filmes consumindo a API autenticada. |
| 12 | CRUD de filmes: criar, editar e excluir, com validações e testes. |

*O histórico resume a sequência registrada; os materiais da disciplina contêm os enunciados completos.*

## Como executar

### Backend

```powershell
cd backend
poetry install
poetry run uvicorn app.main:app --reload
```

Documentação interativa: http://127.0.0.1:8000/docs

### Flutter

Com a API em execução, abra outro terminal:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

Verificação e testes:

```powershell
flutter analyze lib
flutter test
```

### Protótipo Lovable

O protótipo utiliza React/TypeScript e dependências próprias. Deve permanecer em pasta separada: serve como referência visual e funcional, não substitui o Flutter nem o backend.

## Próxima etapa: integração visual

Ajustar progressivamente as telas Flutter com base no protótipo: identidade visual, hierarquia, formulários, filtros, estados vazios/erro/carregamento e navegação. A integração FastAPI e os testes existentes devem ser preservados.
