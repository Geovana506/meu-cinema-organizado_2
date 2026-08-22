# Meu Cinema Organizado

API feita com **FastAPI** para organizar meu catálogo pessoal de filmes.

## Endpoints

- `GET /` — mensagem de boas-vindas da API
- `GET /filmes` — lista os filmes do catálogo (dados fixos)

## Como rodar

```bash
poetry install
poetry run uvicorn main:app --reload
```

Depois acesse `http://127.0.0.1:8000/docs` para ver a documentação interativa (Swagger UI).
