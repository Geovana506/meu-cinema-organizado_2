import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  ErroDeLogin(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

// Estado compartilhado de autenticação. As telas observam este objeto
// com Provider, sem receber SessaoService pelos construtores.
class SessaoService extends ChangeNotifier {
  SessaoService(this.repository);

  final UsuarioRepository repository;

  String? token;
  Usuario? usuario;

  bool get logado => token != null && usuario != null;

  Future<void> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha.');
    }

    try {
      final novoToken = await repository.entrar(email.trim(), senha);
      if (novoToken == null) {
        throw ErroDeLogin('E-mail ou senha incorretos.');
      }
      final usuarioAutenticado = await repository.quemSouEu(novoToken);
      token = novoToken;
      usuario = usuarioAutenticado;
      notifyListeners();
    } on ErroDeLogin {
      rethrow;
    } catch (_) {
      throw ErroDeLogin('Não foi possível conectar à API ou validar sua sessão.');
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

  void sair() {
    token = null;
    usuario = null;
    notifyListeners();
  }
}
