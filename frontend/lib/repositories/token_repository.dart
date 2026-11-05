import 'package:shared_preferences/shared_preferences.dart';

// Único ponto do app que conhece o armazenamento persistente do dispositivo.
class TokenRepository {
  static const _chave = 'token';

  Future<String?> ler() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(_chave);
  }

  Future<void> salvar(String token) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_chave, token);
  }

  Future<void> apagar() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_chave);
  }
}
