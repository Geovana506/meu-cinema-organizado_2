from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UsuarioCriacao(BaseModel):
    nome: str = Field(min_length=2, max_length=100)
    email: EmailStr
    senha: str = Field(min_length=6, max_length=72)


class UsuarioResposta(BaseModel):
    id: int
    nome: str
    email: EmailStr
    model_config = ConfigDict(from_attributes=True)


class TokenResposta(BaseModel):
    access_token: str
    token_type: str = "bearer"
