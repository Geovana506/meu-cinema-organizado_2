import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/filme.dart';
import 'usuario_repository.dart';

class FilmeRepository {
  FilmeRepository({http.Client? cliente})
      : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  Future<List<Filme>> listar(String token) async {
    final resposta = await _cliente.get(
      Uri.parse('$enderecoDaApi/filmes/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }

    final dados = jsonDecode(resposta.body) as List<dynamic>;
    return dados
        .map((item) => Filme.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Filme> buscar(String token, int id) async {
    final resposta = await _cliente.get(
      Uri.parse('$enderecoDaApi/filmes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }

    return Filme.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<Filme> criar(
    String token, {
    required String titulo,
    required String diretor,
    required int ano,
    required String genero,
    required int duracaoMinutos,
    required bool assistido,
  }) async {
    final resposta = await _cliente.post(
      Uri.parse('$enderecoDaApi/filmes/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'titulo': titulo,
        'diretor': diretor,
        'ano': ano,
        'genero': genero,
        'duracao_minutos': duracaoMinutos,
        'assistido': assistido,
      }),
    );
    if (resposta.statusCode != 201) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }

    return Filme.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<Filme> atualizar(
    String token,
    int id, {
    required String titulo,
    required String diretor,
    required int ano,
    required String genero,
    required int duracaoMinutos,
    required bool assistido,
  }) async {
    final resposta = await _cliente.patch(
      Uri.parse('$enderecoDaApi/filmes/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'titulo': titulo,
        'diretor': diretor,
        'ano': ano,
        'genero': genero,
        'duracao_minutos': duracaoMinutos,
        'assistido': assistido,
      }),
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }

    return Filme.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<void> excluir(String token, int id) async {
    final resposta = await _cliente.delete(
      Uri.parse('$enderecoDaApi/filmes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 204) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
  }

  String _frase(String corpo) {
    try {
      final detalhe = (jsonDecode(corpo) as Map<String, dynamic>)['detail'];
      if (detalhe is String) return detalhe;
      if (detalhe is List && detalhe.isNotEmpty) {
        final primeiro = detalhe.first as Map<String, dynamic>;
        final local = primeiro['loc'];
        final campo = local is List && local.isNotEmpty ? local.last : 'campo';
        final mensagem = (primeiro['msg'] ?? 'valor inválido').toString()
            .replaceFirst('Value error, ', '');
        return '$campo: $mensagem';
      }
    } catch (_) {}
    return 'A API recusou a solicitação.';
  }
}
