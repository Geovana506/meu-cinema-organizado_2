from app.seguranca import conferir_senha, criar_token, gerar_hash
from app.usuarios.erros import CredenciaisInvalidas, EmailJaCadastrado
from app.usuarios.repository import UsuarioRepository


class UsuarioService:
    def __init__(self, repository: UsuarioRepository):
        self.repository = repository

    def cadastrar(self, dados: dict):
        email = str(dados["email"]).lower()
        if self.repository.buscar_por_email(email):
            raise EmailJaCadastrado("Este e-mail já está cadastrado.")
        return self.repository.criar({
            "nome": dados["nome"].strip(),
            "email": email,
            "senha_hash": gerar_hash(dados["senha"]),
        })

    def autenticar(self, email: str, senha: str):
        usuario = self.repository.buscar_por_email(email.lower())
        if usuario is None or not conferir_senha(senha, usuario.senha_hash):
            raise CredenciaisInvalidas("E-mail ou senha incorretos.")
        return criar_token(usuario.id)
