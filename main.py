from fastapi import FastAPI

app = FastAPI(
    title="Meu Cinema Organizado",
    description="API para organizar meu catálogo pessoal de filmes",
    version="0.1.0",
)


@app.get("/")
def read_root():
    """Endpoint raiz da API."""
    return {"mensagem": "Bem-vindo à API do Meu Cinema Organizado!"}
