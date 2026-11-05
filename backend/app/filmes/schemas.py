from pydantic import BaseModel, ConfigDict, Field


class FilmeBase(BaseModel):
    titulo: str = Field(min_length=1, max_length=150)
    diretor: str = Field(min_length=1, max_length=120)
    ano: int = Field(ge=1888, le=2100)
    genero: str = Field(min_length=1, max_length=80)
    duracao_minutos: int = Field(gt=0, le=1000)
    assistido: bool = False


class FilmeCriacao(FilmeBase):
    pass


class FilmeAtualizacao(BaseModel):
    titulo: str | None = Field(default=None, min_length=1, max_length=150)
    diretor: str | None = Field(default=None, min_length=1, max_length=120)
    ano: int | None = Field(default=None, ge=1888, le=2100)
    genero: str | None = Field(default=None, min_length=1, max_length=80)
    duracao_minutos: int | None = Field(default=None, gt=0, le=1000)
    assistido: bool | None = None


class FilmeResposta(FilmeBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
