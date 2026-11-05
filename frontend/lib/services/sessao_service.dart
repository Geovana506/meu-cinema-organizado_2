import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/token_repository.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  ErroDeLogin(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}
class ErroDeCadastro implements Exception {
  ErroDeCadastro(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

class SessaoService extends ChangeNotifier {
  SessaoService(this.repositorio, {TokenRepository? tokens})
      : tokens = tokens ?? TokenRepository();

  final UsuarioRepository repositorio;
  final TokenRepository tokens;
  String? token;
  Usuario? usuario;
  bool get logado => token != null && usuario != null;

  Future<void> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha.');
    }
    try {
      final recebido = await repositorio.entrar(email.trim(), senha);
      if (recebido == null) throw ErroDeLogin('E-mail ou senha incorretos.');
      final quem = await repositorio.quemSouEu(recebido);
      await tokens.salvar(recebido);
      token = recebido;
      usuario = quem;
      notifyListeners();
    } on ErroDeLogin {
      rethrow;
    } on RecusaDaApi catch (e) {
      throw ErroDeLogin(e.status == 401 ? 'E-mail ou senha incorretos.' : e.mensagem);
    } catch (_) {
      throw ErroDeLogin('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  Future<void> cadastrar(String nome, String email, String senha) async {
    if (nome.trim().length < 2 || email.trim().isEmpty || senha.isEmpty) {
      throw ErroDeCadastro('Preencha os campos corretamente.');
    }
    try {
      await repositorio.cadastrar(nome.trim(), email.trim(), senha);
      await entrar(email.trim(), senha);
    } on RecusaDaApi catch (e) {
      if (e.status == 409) {
        throw ErroDeCadastro('Já existe uma conta com este e-mail.');
      }
      throw ErroDeCadastro(e.mensagem);
    } on ErroDeLogin {
      throw ErroDeCadastro('Conta criada, mas não consegui entrar. Tente pelo login.');
    } catch (_) {
      throw ErroDeCadastro('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  Future<void> restaurar() async {
    final guardado = await tokens.ler();
    if (guardado == null || guardado.isEmpty) return;
    try {
      final quem = await repositorio.quemSouEu(guardado);
      token = guardado;
      usuario = quem;
      notifyListeners();
    } on RecusaDaApi {
      await tokens.apagar();
      token = null;
      usuario = null;
      notifyListeners();
    } catch (_) {
      // Sem resposta da API não significa que o token venceu: preserve-o.
    }
  }

  Future<void> sair() async {
    await tokens.apagar();
    token = null;
    usuario = null;
    notifyListeners();
  }
}
