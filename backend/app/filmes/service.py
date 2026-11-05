from app.filmes.erros import FilmeDuplicado, FilmeNaoEncontrado
from app.filmes.repository import FilmeRepository


class FilmeService:
    def __init__(self, repository: FilmeRepository):
        self.repository = repository

    def listar(self):
        return self.repository.listar()

    def buscar(self, filme_id: int):
        filme = self.repository.buscar_por_id(filme_id)
        if filme is None:
            raise FilmeNaoEncontrado("Filme não encontrado.")
        return filme

    def criar(self, dados: dict):
        if self.repository.buscar_por_titulo_ano(dados["titulo"], dados["ano"]):
            raise FilmeDuplicado("Já existe um filme com esse título e ano.")
        return self.repository.criar(dados)

    def atualizar(self, filme_id: int, dados: dict):
        filme = self.buscar(filme_id)
        alteracoes = {k: v for k, v in dados.items() if v is not None}
        titulo = alteracoes.get("titulo", filme.titulo)
        ano = alteracoes.get("ano", filme.ano)
        existente = self.repository.buscar_por_titulo_ano(titulo, ano)
        if existente and existente.id != filme.id:
            raise FilmeDuplicado("Já existe um filme com esse título e ano.")
        for chave, valor in alteracoes.items():
            setattr(filme, chave, valor)
        return self.repository.salvar(filme)

    def excluir(self, filme_id: int):
        filme = self.buscar(filme_id)
        self.repository.excluir(filme)
