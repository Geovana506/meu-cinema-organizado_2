import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class UsuarioRepository {
  UsuarioRepository({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  // Chrome/Desktop: 127.0.0.1. Android Emulator: 10.0.2.2.
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<String?> entrar(String email, String senha) async {
    final response = await _cliente.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': senha},
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['access_token'] as String?;
  }

  Future<Usuario> cadastrar(String nome, String email, String senha) async {
    final response = await _cliente.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Usuario.fromJson(body as Map<String, dynamic>);
    }
    final detalhe = body is Map<String, dynamic>
        ? (body['detail']?.toString() ?? 'Não foi possível realizar o cadastro.')
        : 'Não foi possível realizar o cadastro.';
    throw Exception(detalhe);
  }

  Future<Usuario> quemSouEu(String token) async {
    final response = await _cliente.get(
      Uri.parse('$baseUrl/usuarios/eu'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Sua sessão expirou. Entre novamente.');
    }
    return Usuario.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
