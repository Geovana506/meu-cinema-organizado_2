from sqlalchemy import select
from sqlalchemy.orm import Session

from app.usuarios.models import Usuario


class UsuarioRepository:
    def __init__(self, db: Session):
        self.db = db

    def buscar_por_id(self, usuario_id: int):
        return self.db.get(Usuario, usuario_id)

    def buscar_por_email(self, email: str):
        return self.db.scalar(select(Usuario).where(Usuario.email == email))

    def criar(self, dados: dict):
        usuario = Usuario(**dados)
        self.db.add(usuario)
        self.db.commit()
        self.db.refresh(usuario)
        return usuario
