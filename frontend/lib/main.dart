import 'package:flutter/material.dart';

import 'repositories/usuario_repository.dart';
import 'screens/login_screen.dart';
import 'services/sessao_service.dart';

void main() {
  final sessao = SessaoService(UsuarioRepository());
  runApp(MeuCinemaApp(sessao: sessao));
}

class MeuCinemaApp extends StatelessWidget {
  const MeuCinemaApp({super.key, required this.sessao});
  final SessaoService sessao;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Cinema Organizado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B1C31)),
        useMaterial3: true,
      ),
      home: LoginScreen(sessao: sessao),
    );
  }
}
