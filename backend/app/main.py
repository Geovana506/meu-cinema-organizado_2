from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, SessionLocal, engine
from app.filmes.controller import router as filmes_router
from app.filmes.models import Filme
from app.usuarios.controller import router as usuarios_router
from app.usuarios.models import Usuario  # registra a tabela no metadata

app = FastAPI(
    title="Meu Cinema Organizado",
    description="API para organizar meu catálogo pessoal de filmes",
    version="0.2.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)


def inserir_filmes_iniciais():
    with SessionLocal() as db:
        if db.query(Filme).count() == 0:
            db.add_all([
                Filme(titulo="O Poderoso Chefão", diretor="Francis Ford Coppola", ano=1972,
                      genero="Drama", duracao_minutos=175, assistido=True),
                Filme(titulo="Cidade de Deus", diretor="Fernando Meirelles", ano=2002,
                      genero="Drama/Crime", duracao_minutos=130, assistido=True),
                Filme(titulo="Interestelar", diretor="Christopher Nolan", ano=2014,
                      genero="Ficção Científica", duracao_minutos=169, assistido=False),
                Filme(titulo="Parasita", diretor="Bong Joon-ho", ano=2019,
                      genero="Suspense/Drama", duracao_minutos=132, assistido=False),
            ])
            db.commit()


inserir_filmes_iniciais()


@app.get("/")
def inicio():
    return {"mensagem": "Bem-vindo à API do Meu Cinema Organizado!"}


app.include_router(usuarios_router)
app.include_router(filmes_router)
