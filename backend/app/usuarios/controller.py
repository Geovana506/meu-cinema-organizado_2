from fastapi import APIRouter, Depends, Form, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.seguranca import get_current_user
from app.usuarios.erros import CredenciaisInvalidas, EmailJaCadastrado
from app.usuarios.repository import UsuarioRepository
from app.usuarios.schemas import TokenResposta, UsuarioCriacao, UsuarioResposta
from app.usuarios.service import UsuarioService

router = APIRouter(prefix="/usuarios", tags=["Usuários"])


def obter_service(db: Session = Depends(get_db)):
    return UsuarioService(UsuarioRepository(db))


@router.post("/", response_model=UsuarioResposta, status_code=status.HTTP_201_CREATED)
def cadastrar(dados: UsuarioCriacao, service: UsuarioService = Depends(obter_service)):
    try:
        return service.cadastrar(dados.model_dump())
    except EmailJaCadastrado as erro:
        raise HTTPException(status_code=409, detail=str(erro))


@router.post("/login", response_model=TokenResposta)
def login(
    username: str = Form(...),
    password: str = Form(...),
    service: UsuarioService = Depends(obter_service),
):
    try:
        return {"access_token": service.autenticar(username, password), "token_type": "bearer"}
    except CredenciaisInvalidas as erro:
        raise HTTPException(status_code=401, detail=str(erro), headers={"WWW-Authenticate": "Bearer"})


@router.get("/eu", response_model=UsuarioResposta)
def usuario_atual(usuario=Depends(get_current_user)):
    return usuario
