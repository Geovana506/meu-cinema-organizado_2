from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.filmes.erros import FilmeDuplicado, FilmeNaoEncontrado
from app.filmes.repository import FilmeRepository
from app.filmes.schemas import FilmeAtualizacao, FilmeCriacao, FilmeResposta
from app.filmes.service import FilmeService
from app.seguranca import get_current_user

router = APIRouter(prefix="/filmes", tags=["Filmes"], dependencies=[Depends(get_current_user)])


def obter_service(db: Session = Depends(get_db)):
    return FilmeService(FilmeRepository(db))


@router.get("/", response_model=list[FilmeResposta])
def listar_filmes(service: FilmeService = Depends(obter_service)):
    return service.listar()


@router.get("/{filme_id}", response_model=FilmeResposta)
def buscar_filme(filme_id: int, service: FilmeService = Depends(obter_service)):
    try:
        return service.buscar(filme_id)
    except FilmeNaoEncontrado as erro:
        raise HTTPException(status_code=404, detail=str(erro))


@router.post("/", response_model=FilmeResposta, status_code=status.HTTP_201_CREATED)
def criar_filme(dados: FilmeCriacao, service: FilmeService = Depends(obter_service)):
    try:
        return service.criar(dados.model_dump())
    except FilmeDuplicado as erro:
        raise HTTPException(status_code=409, detail=str(erro))


@router.patch("/{filme_id}", response_model=FilmeResposta)
def atualizar_filme(filme_id: int, dados: FilmeAtualizacao, service: FilmeService = Depends(obter_service)):
    try:
        return service.atualizar(filme_id, dados.model_dump(exclude_unset=True))
    except FilmeNaoEncontrado as erro:
        raise HTTPException(status_code=404, detail=str(erro))
    except FilmeDuplicado as erro:
        raise HTTPException(status_code=409, detail=str(erro))


@router.delete("/{filme_id}", status_code=status.HTTP_204_NO_CONTENT)
def excluir_filme(filme_id: int, service: FilmeService = Depends(obter_service)):
    try:
        service.excluir(filme_id)
    except FilmeNaoEncontrado as erro:
        raise HTTPException(status_code=404, detail=str(erro))
    return Response(status_code=status.HTTP_204_NO_CONTENT)
