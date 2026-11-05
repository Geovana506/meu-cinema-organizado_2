import '../models/filme.dart';
import '../repositories/filme_repository.dart';
import '../repositories/usuario_repository.dart';
import 'sessao_service.dart';

class ErroDeFilmes implements Exception {
  ErroDeFilmes(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class FilmeService {
  FilmeService(this.repositorio, this.sessao);

  final FilmeRepository repositorio;
  final SessaoService sessao;

  String get _token {
    final token = sessao.token;
    if (token == null || token.isEmpty) {
      throw ErroDeFilmes('Você precisa entrar para consultar seus filmes.');
    }
    return token;
  }

  Future<List<Filme>> listar() async {
    try {
      return await repositorio.listar(_token);
    } on RecusaDaApi catch (e) {
      throw ErroDeFilmes(e.mensagem);
    } catch (e) {
      if (e is ErroDeFilmes) rethrow;
      throw ErroDeFilmes(
        'Não consegui falar com a API. O uvicorn está rodando?',
      );
    }
  }

  Future<Filme> buscar(int id) async {
    try {
      return await repositorio.buscar(_token, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeFilmes(e.mensagem);
    } catch (e) {
      if (e is ErroDeFilmes) rethrow;
      throw ErroDeFilmes(
        'Não consegui falar com a API. O uvicorn está rodando?',
      );
    }
  }
}
