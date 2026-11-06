from sqlalchemy import select
from sqlalchemy.orm import Session

from app.filmes.models import Filme


class FilmeRepository:
    def __init__(self, db: Session):
        self.db = db

    def listar(self):
        return list(self.db.scalars(select(Filme).order_by(Filme.id)).all())

    def buscar_por_id(self, filme_id: int):
        return self.db.get(Filme, filme_id)

    def buscar_por_titulo_ano(self, titulo: str, ano: int):
        return self.db.scalar(
            select(Filme).where(Filme.titulo.ilike(titulo), Filme.ano == ano)
        )

    def criar(self, dados: dict):
        filme = Filme(**dados)
        self.db.add(filme)
        self.db.commit()
        self.db.refresh(filme)
        return filme

    def salvar(self, filme: Filme):
        self.db.commit()
        self.db.refresh(filme)
        return filme

    def excluir(self, filme: Filme):
        self.db.delete(filme)
        self.db.commit()
