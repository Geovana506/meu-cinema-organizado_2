# Meu Cinema Organizado

Projeto acadêmico composto por uma API **FastAPI** e um aplicativo **Flutter** para organizar um catálogo pessoal de filmes.

## Estrutura

- `backend/`: API, banco SQLite, SQLAlchemy e autenticação JWT.
- `frontend/`: aplicativo Flutter com cadastro, login, navegação nomeada e sessão compartilhada com Provider.

## Backend

Requisitos: Python 3.11+ e Poetry.

Na primeira execução:

```bash
cd backend
cp .env.example .env
```

Edite o arquivo `.env` e substitua `SECRET_KEY` por uma chave aleatória longa (pelo menos 32 caracteres). Depois:

```bash
poetry lock
poetry install
poetry run uvicorn app.main:app --reload
```

A documentação interativa estará em http://127.0.0.1:8000/docs.

O SQLite cria o arquivo `meu_cinema.db` dentro de `backend/`. Os quatro filmes iniciais são inseridos automaticamente quando a tabela está vazia.

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
flutter analyze
flutter test
```

## Autenticação e navegação

- Cadastro: `POST /usuarios/`.
- Login: `POST /usuarios/login`; o campo `username` recebe o e-mail.
- Usuário autenticado: `GET /usuarios/eu`.
- As rotas de filmes exigem token Bearer.
- A senha é armazenada como hash bcrypt, nunca em texto puro.
- O JWT expira em 60 minutos.
- As telas possuem nomes centralizados em `lib/routes.dart`; o `main.dart` associa cada rota à tela correspondente.
- As telas internas passam por `RotaProtegida`; sem sessão, o aplicativo mostra o login.
- A sessão (`SessaoService`) fica no topo da árvore de widgets com `ChangeNotifierProvider`. As telas usam `context.read` para executar ações e `context.watch` para acompanhar alterações.
- O menu lateral apresenta o nome e o e-mail da pessoa autenticada, permite navegar entre Início, Filmes e Perfil e oferece a opção Sair.
- O token permanece apenas na memória do aplicativo nesta etapa. Ao atualizar a página (F5) ou reiniciar o app, será necessário entrar novamente.

## Regras do catálogo

A situação `assistido` indica se a pessoa já viu o filme. Ela não representa disponibilidade para empréstimo. O sistema evita cadastrar filmes com o mesmo título e ano. A tela de filmes desta etapa é apenas um espaço reservado para a listagem que será desenvolvida nos próximos encontros.


## Encontro 10 — cadastro e sessão persistente

O cadastro do aplicativo chama `POST /usuarios/` pelo `UsuarioRepository`, com validações e tratamento das recusas da API. Quando a conta é criada, o app reutiliza o fluxo de login e já abre a tela inicial.

O token JWT é guardado pelo `TokenRepository`, usando `shared_preferences` (no Chrome, o armazenamento local do navegador). Antes de abrir a primeira tela, o `main` chama `SessaoService.restaurar()`: se a API confirmar o token, a pessoa continua autenticada após F5 ou reinicialização. Se a API responder que o token não é válido, ele é apagado. Se a API estiver indisponível, o token é preservado para uma nova tentativa posterior.

A opção **Sair** apaga o token do armazenamento local e da memória da aplicação. O token não é invalidado no servidor: uma cópia roubada continua válida até expirar ou ser rejeitada pela API; por isso, o app deve ser usado em dispositivo confiável.


## Encontro 10 — cadastro e sessão persistente

O cadastro do aplicativo chama `POST /usuarios/` pelo `UsuarioRepository`, com tratamento das recusas da API. Quando a conta é criada, o `SessaoService` reutiliza o fluxo de login e a pessoa já entra na tela inicial.

O token JWT é guardado pelo `TokenRepository`, usando `shared_preferences` (no Chrome, o armazenamento local do navegador). Antes de abrir a primeira tela, o `main` chama `SessaoService.restaurar()`: se a API confirmar o token, a sessão é recuperada após F5 ou reinicialização. Se a API responder que o token não é válido, ele é apagado. Se a API estiver indisponível, o token é preservado, pois a falha de conexão não prova que ele venceu.

A opção **Sair** apaga o token do armazenamento local e da memória do aplicativo. Ela não revoga o JWT no servidor: uma cópia do token ainda poderá ser usada até expirar ou ser rejeitada pela API. Por isso, use o app em um dispositivo confiável.


## Encontro 11 — listagem e detalhe dos filmes

A tela **Meus filmes** consulta `GET /filmes/` pelas camadas do aplicativo: `FilmesScreen`, `FilmeService` e `FilmeRepository`. O repositório envia o token JWT no cabeçalho `Authorization: Bearer` e transforma cada registro recebido em um objeto `Filme`. A tela apresenta quatro estados: carregamento, erro com a opção **Tentar de novo**, lista vazia e lista de filmes em ordem alfabética.

Ao tocar em um filme, o aplicativo abre a rota `/filme` enviando apenas o identificador nos `arguments`. A tela de detalhe consulta novamente a API por `GET /filmes/{id}` e apresenta título, diretor, ano, gênero, duração e situação (assistido ou não assistido). Se a página for atualizada sem os argumentos de navegação, o aplicativo retorna à lista.

**Observação sobre o escopo atual da API:** as rotas de filmes exigem autenticação, mas o modelo `Filme` ainda não possui relacionamento com o usuário. Portanto, neste estágio, a API retorna o catálogo compartilhado entre as contas autenticadas; ela ainda não filtra filmes por proprietário.


## Encontro 12 — CRUD de filmes pelo aplicativo

O aplicativo permite cadastrar, editar e excluir filmes pelas camadas `FilmesScreen`, `FilmeScreen`, `FormularioScreen`, `FilmeService` e `FilmeRepository`. O formulário único recebe título, diretor, ano, gênero, duração em minutos e situação de assistido; ele é reutilizado tanto para um novo cadastro quanto para a edição de um filme existente.

O repositório envia o token JWT no cabeçalho `Authorization: Bearer` e usa `POST /filmes/` para criar, `PATCH /filmes/{id}` para atualizar e `DELETE /filmes/{id}` para excluir. A situação `assistido` é enviada como um campo do registro; ela não representa disponibilidade para empréstimo. O backend valida os campos e impede duplicidade de título e ano.

O formulário também valida os campos antes de chamar a API: título, diretor e gênero são obrigatórios; o ano deve estar entre 1888 e 2100; a duração deve estar entre 1 e 1000 minutos. As recusas da API, como dados inválidos (422) ou filme duplicado (409), são apresentadas no próprio formulário. A exclusão pede confirmação em um diálogo. Depois de salvar ou excluir com sucesso, a navegação retorna um resultado `true`, e a listagem consulta os filmes novamente. Se a rota do formulário for aberta sem os argumentos de navegação (por exemplo, após F5), o app retorna à lista.
