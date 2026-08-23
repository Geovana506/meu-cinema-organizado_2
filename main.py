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


@app.get("/filmes")
def listar_filmes():
    """Retorna a lista de filmes do catálogo (dados fixos, em memória)."""
    filmes = [
        {
            "id": 1,
            "titulo": "O Poderoso Chefão",
            "diretor": "Francis Ford Coppola",
            "ano": 1972,
            "genero": "Drama",
            "duracao_minutos": 175,
            "assistido": True,
        },
        {
            "id": 2,
            "titulo": "Cidade de Deus",
            "diretor": "Fernando Meirelles",
            "ano": 2002,
            "genero": "Drama/Crime",
            "duracao_minutos": 130,
            "assistido": True,
        },
        {
            "id": 3,
            "titulo": "Interestelar",
            "diretor": "Christopher Nolan",
            "ano": 2014,
            "genero": "Ficção Científica",
            "duracao_minutos": 169,
            "assistido": False,
        },
        {
            "id": 4,
            "titulo": "Parasita",
            "diretor": "Bong Joon-ho",
            "ano": 2019,
            "genero": "Suspense/Drama",
            "duracao_minutos": 132,
            "assistido": False,
        },
    ]
    return filmes
