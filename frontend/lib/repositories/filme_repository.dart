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

  String _frase(String corpo) {
    try {
      final detalhe = (jsonDecode(corpo) as Map<String, dynamic>)['detail'];
      if (detalhe is String) return detalhe;
    } catch (_) {}
    return 'A API recusou a solicitação.';
  }
}
