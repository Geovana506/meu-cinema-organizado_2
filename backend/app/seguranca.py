import os
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from dotenv import load_dotenv
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jwt import InvalidTokenError
from sqlalchemy.orm import Session

from app.database import get_db
from app.usuarios.repository import UsuarioRepository

load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY or len(SECRET_KEY) < 32:
    raise RuntimeError("Configure SECRET_KEY com pelo menos 32 caracteres no arquivo .env.")
ALGORITMO = "HS256"
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/usuarios/login")


def gerar_hash(senha: str) -> str:
    return bcrypt.hashpw(senha.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def conferir_senha(senha: str, senha_hash: str) -> bool:
    try:
        return bcrypt.checkpw(senha.encode("utf-8"), senha_hash.encode("utf-8"))
    except ValueError:
        return False


def criar_token(usuario_id: int) -> str:
    agora = datetime.now(timezone.utc)
    payload = {"sub": str(usuario_id), "iat": agora, "exp": agora + timedelta(minutes=60)}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITMO)


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credenciais = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Não foi possível validar as credenciais.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITMO])
        subject = payload.get("sub")
        if not subject:
            raise credenciais
        usuario_id = int(subject)
    except (InvalidTokenError, ValueError, TypeError):
        raise credenciais

    usuario = UsuarioRepository(db).buscar_por_id(usuario_id)
    if usuario is None:
        raise credenciais
    return usuario
