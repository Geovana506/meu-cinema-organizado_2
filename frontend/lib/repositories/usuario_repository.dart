import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

const enderecoDaApi = 'http://127.0.0.1:8000';

class RecusaDaApi implements Exception {
  RecusaDaApi(this.status, this.mensagem);
  final int status;
  final String mensagem;
  @override
  String toString() => mensagem;
}

class UsuarioRepository {
  UsuarioRepository({http.Client? cliente}) : _cliente = cliente ?? http.Client();
  final http.Client _cliente;

  Future<String?> entrar(String email, String senha) async {
    final resposta = await _cliente.post(
      Uri.parse('$enderecoDaApi/usuarios/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': senha},
    );
    if (resposta.statusCode != 200) return null;
    final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
    return corpo['access_token'] as String?;
  }

  Future<Usuario> cadastrar(String nome, String email, String senha) async {
    final resposta = await _cliente.post(
      Uri.parse('$enderecoDaApi/usuarios/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );
    if (resposta.statusCode != 201) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Usuario.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<Usuario> quemSouEu(String token) async {
    final resposta = await _cliente.get(
      Uri.parse('$enderecoDaApi/usuarios/eu'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Usuario.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  String _frase(String corpo) {
    try {
      final detalhe = (jsonDecode(corpo) as Map<String, dynamic>)['detail'];
      if (detalhe is String) return detalhe;
      if (detalhe is List && detalhe.isNotEmpty) {
        final primeiro = detalhe.first as Map<String, dynamic>;
        final local = primeiro['loc'];
        final campo = local is List && local.isNotEmpty ? local.last : 'campo';
        return '$campo: ${primeiro['msg'] ?? 'valor inválido'}';
      }
    } catch (_) {}
    return 'A API recusou a solicitação.';
  }
}
