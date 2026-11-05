import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  ErroDeLogin(this.mensagem);
  final String mensagem;
}

class SessaoService {
  SessaoService(this.repository);
  final UsuarioRepository repository;
  String? _token;

  bool get autenticado => _token != null;

  Future<void> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha.');
    }
    try {
      final token = await repository.entrar(email.trim(), senha);
      if (token == null) throw ErroDeLogin('E-mail ou senha incorretos.');
      _token = token;
    } on ErroDeLogin {
      rethrow;
    } catch (_) {
      throw ErroDeLogin('Não foi possível conectar à API.');
    }
  }

  Future<Usuario> usuarioLogado() async {
    final token = _token;
    if (token == null) throw ErroDeLogin('Faça login novamente.');
    try {
      return await repository.quemSouEu(token);
    } catch (_) {
      sair();
      throw ErroDeLogin('Não foi possível validar sua sessão. Entre novamente.');
    }
  }

  Future<void> cadastrar(String nome, String email, String senha) async {
    if (nome.trim().length < 2 || email.trim().isEmpty || senha.length < 6) {
      throw ErroDeLogin('Confira os dados. A senha deve ter pelo menos 6 caracteres.');
    }
    try {
      await repository.cadastrar(nome.trim(), email.trim(), senha);
    } catch (erro) {
      throw ErroDeLogin(erro.toString().replaceFirst('Exception: ', ''));
    }
  }

  void sair() => _token = null;
}
