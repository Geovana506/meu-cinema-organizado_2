import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/filme.dart';
import 'repositories/filme_repository.dart';
import 'repositories/token_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/cadastro_screen.dart';
import 'screens/filme_screen.dart';
import 'screens/filmes_screen.dart';
import 'screens/formulario_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'services/filme_service.dart';
import 'services/sessao_service.dart';
import 'widgets/rota_protegida.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessao = SessaoService(
    UsuarioRepository(),
    tokens: TokenRepository(),
  );
  await sessao.restaurar();

  final filmes = FilmeService(FilmeRepository(), sessao);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        Provider<FilmeService>.value(value: filmes),
      ],
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF356B70),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFEAF1EF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEAF1EF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF356B70), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.cadastro: (_) => const CadastroScreen(),
        AppRoutes.inicio: (_) => const RotaProtegida(tela: InicioScreen()),
        AppRoutes.filmes: (_) => const RotaProtegida(tela: FilmesScreen()),
        AppRoutes.perfil: (_) => const RotaProtegida(tela: PerfilScreen()),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.filme) {
          final id = settings.arguments;
          if (id is int) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => RotaProtegida(
                tela: FilmeScreen(filmeId: id),
              ),
            );
          }
          return MaterialPageRoute<void>(
            builder: (_) => const RotaProtegida(tela: FilmesScreen()),
          );
        }
        if (settings.name == AppRoutes.formulario) {
          final argumento = settings.arguments;
          if (argumento == true || argumento is Filme) {
            return MaterialPageRoute<bool>(
              settings: settings,
              builder: (_) => RotaProtegida(
                tela: FormularioScreen(
                  filme: argumento is Filme ? argumento : null,
                ),
              ),
            );
          }
          // Sem arguments (por exemplo, após F5), não há contexto para editar.
          return MaterialPageRoute<void>(
            builder: (_) => const RotaProtegida(tela: FilmesScreen()),
          );
        }
        return null;
      },
    );
  }
}
