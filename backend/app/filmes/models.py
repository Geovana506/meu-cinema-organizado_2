from sqlalchemy import Boolean, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Filme(Base):
    __tablename__ = "filmes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    titulo: Mapped[str] = mapped_column(String(150), nullable=False, index=True)
    diretor: Mapped[str] = mapped_column(String(120), nullable=False)
    ano: Mapped[int] = mapped_column(Integer, nullable=False)
    genero: Mapped[str] = mapped_column(String(80), nullable=False)
    duracao_minutos: Mapped[int] = mapped_column(Integer, nullable=False)
    assistido: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
