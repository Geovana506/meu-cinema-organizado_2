import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/cadastro_screen.dart';
import 'screens/filmes_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'services/sessao_service.dart';
import 'widgets/rota_protegida.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessaoService(UsuarioRepository()),
      child: const MeuCinemaApp(),
    ),
  );
}

class MeuCinemaApp extends StatelessWidget {
  const MeuCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Cinema Organizado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B1C31)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.cadastro: (_) => const CadastroScreen(),
        AppRoutes.inicio: (_) =>
            const RotaProtegida(tela: InicioScreen()),
        AppRoutes.filmes: (_) =>
            const RotaProtegida(tela: FilmesScreen()),
        AppRoutes.perfil: (_) =>
            const RotaProtegida(tela: PerfilScreen()),
      },
    );
  }
}
