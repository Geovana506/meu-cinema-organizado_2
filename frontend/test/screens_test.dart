import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meu_cinema_organizado/main.dart';
import 'package:meu_cinema_organizado/models/filme.dart';
import 'package:meu_cinema_organizado/repositories/filme_repository.dart';
import 'package:meu_cinema_organizado/repositories/usuario_repository.dart';
import 'package:meu_cinema_organizado/routes.dart';
import 'package:meu_cinema_organizado/screens/cadastro_screen.dart';
import 'package:meu_cinema_organizado/screens/filme_screen.dart';
import 'package:meu_cinema_organizado/screens/filmes_screen.dart';
import 'package:meu_cinema_organizado/screens/inicio_screen.dart';
import 'package:meu_cinema_organizado/screens/login_screen.dart';
import 'package:meu_cinema_organizado/screens/perfil_screen.dart';
import 'package:meu_cinema_organizado/services/filme_service.dart';
import 'package:meu_cinema_organizado/services/sessao_service.dart';

int pedidos = 0;

const doisFilmes = [
  {
    'id': 1,
    'titulo': 'O Poderoso Chefão',
    'diretor': 'Francis Ford Coppola',
    'ano': 1972,
    'genero': 'Drama',
    'duracao_minutos': 175,
    'assistido': true,
  },
  {
    'id': 2,
    'titulo': 'Interestelar',
    'diretor': 'Christopher Nolan',
    'ano': 2014,
    'genero': 'Ficção Científica',
    'duracao_minutos': 169,
    'assistido': false,
  },
];

SessaoService sessaoDeMentira({
  Map<String, Object> guardado = const {},
}) {
  SharedPreferences.setMockInitialValues(guardado);
  final cliente = MockClient((pedido) async {
    pedidos++;
    if (pedido.url.path == '/usuarios/login') {
      if (pedido.bodyFields['username'] == 'geovana@exemplo.com' &&
          pedido.bodyFields['password'] == 'segredo123') {
        return http.Response(
          jsonEncode({
            'access_token': 'token-da-geovana',
            'token_type': 'bearer',
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({'detail': 'E-mail ou senha incorretos'}),
        401,
      );
    }
    if (pedido.url.path == '/usuarios/eu' &&
        pedido.headers['Authorization'] == 'Bearer token-da-geovana') {
      return http.Response(
        jsonEncode({
          'id': 1,
          'nome': 'Geovana',
          'email': 'geovana@exemplo.com',
        }),
        200,
      );
    }
    if (pedido.url.path == '/usuarios/' && pedido.method == 'POST') {
      return http.Response(
        jsonEncode({
          'id': 2,
          'nome': 'Nova pessoa',
          'email': 'nova@exemplo.com',
        }),
        201,
      );
    }
    return http.Response(jsonEncode({'detail': 'Token inválido'}), 401);
  });
  return SessaoService(UsuarioRepository(cliente: cliente));
}

http.Client apiDeFilmes({
  int status = 200,
  Object? corpo,
}) {
  return MockClient((pedido) async {
    pedidos++;
    if (pedido.headers['Authorization'] == null) {
      return http.Response(jsonEncode({'detail': 'Not authenticated'}), 401);
    }
    if (pedido.url.path == '/filmes/') {
      return http.Response(jsonEncode(corpo ?? doisFilmes), status);
    }
    final partes = pedido.url.pathSegments;
    if (partes.length >= 2 && partes.last.isNotEmpty) {
      final id = int.tryParse(partes.last);
      for (final filme in doisFilmes) {
        if (filme['id'] == id) {
          return http.Response(jsonEncode(filme), 200);
        }
      }
      return http.Response(
        jsonEncode({'detail': 'Filme não encontrado.'}),
        404,
      );
    }
    return http.Response(jsonEncode({'detail': 'Rota não encontrada'}), 404);
  });
}

Widget appDeTeste(
  SessaoService sessao, {
  http.Client? filmes,
}) {
  final repositorio = FilmeRepository(
    cliente: filmes ?? apiDeFilmes(),
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: sessao),
      Provider<FilmeService>.value(
        value: FilmeService(repositorio, sessao),
      ),
    ],
    child: const MeuCinemaApp(),
  );
}

Future<void> preencherEEntrar(
  WidgetTester tester, {
  String senha = 'segredo123',
}) async {
  await tester.enterText(
    find.byType(TextField).at(0),
    'geovana@exemplo.com',
  );
  await tester.enterText(find.byType(TextField).at(1), senha);
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.pumpAndSettle();
}

Future<void> entrarEAbrirFilmes(
  WidgetTester tester, {
  http.Client? filmes,
}) async {
  await tester.pumpWidget(appDeTeste(sessaoDeMentira(), filmes: filmes));
  await preencherEEntrar(tester);
  await tester.tap(find.text('Ver meus filmes'));
  await tester.pumpAndSettle();
}

Future<String?> tokenGuardado() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

void main() {
  group('Telas de autenticação e navegação', () {
    testWidgets('login apresenta e-mail, senha e botão Entrar', (tester) async {
      await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
      expect(find.text('Criar uma conta'), findsOneWidget);
    });

    testWidgets('cadastro apresenta nome, e-mail e senha', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: sessaoDeMentira(),
          child: const MaterialApp(home: CadastroScreen()),
        ),
      );
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('login correto abre a tela inicial', (tester) async {
      await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
      await preencherEEntrar(tester);
      expect(find.byType(InicioScreen), findsOneWidget);
      expect(find.text('Olá, Geovana!'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('senha incorreta mantém a pessoa no login', (tester) async {
      await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
      await preencherEEntrar(tester, senha: 'senha-errada');
      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('link Criar uma conta abre o cadastro', (tester) async {
      await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
      await tester.tap(find.text('Criar uma conta'));
      await tester.pumpAndSettle();
      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('rota protegida não abre filmes sem sessão', (tester) async {
      await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
      Navigator.of(tester.element(find.byType(LoginScreen)))
          .pushNamed(AppRoutes.filmes);
      await tester.pumpAndSettle();
      expect(find.byType(FilmesScreen), findsNothing);
      expect(find.byType(LoginScreen), findsWidgets);
    });

    testWidgets('menu apresenta os dados da pessoa e abre o perfil',
        (tester) async {
      await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
      await preencherEEntrar(tester);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      final drawer = find.byType(Drawer);
      expect(find.descendant(of: drawer, matching: find.text('Geovana')),
          findsOneWidget);
      expect(
        find.descendant(
          of: drawer,
          matching: find.text('geovana@exemplo.com'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(of: drawer, matching: find.text('Perfil')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PerfilScreen), findsOneWidget);
    });

    testWidgets('Sair apaga sessão e limpa o histórico de navegação',
        (tester) async {
      final sessao = sessaoDeMentira();
      await tester.pumpWidget(appDeTeste(sessao));
      await preencherEEntrar(tester);
      await tester.tap(find.text('Ver meus filmes'));
      await tester.pumpAndSettle();
      expect(find.byType(FilmesScreen), findsOneWidget);
      expect(await tokenGuardado(), 'token-da-geovana');
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(FilmesScreen), findsNothing);
      expect(sessao.logado, isFalse);
      expect(await tokenGuardado(), isNull);
      expect(
        Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
        isFalse,
      );
    });

    testWidgets('sessão restaurada abre direto no início', (tester) async {
      final sessao = sessaoDeMentira(
        guardado: {'token': 'token-da-geovana'},
      );
      await sessao.restaurar();
      await tester.pumpWidget(appDeTeste(sessao));
      expect(find.byType(InicioScreen), findsOneWidget);
      expect(find.text('Olá, Geovana!'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('watch atualiza a interface quando a sessão muda',
        (tester) async {
      final sessao = sessaoDeMentira();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: sessao,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final nome = context.watch<SessaoService>().usuario?.nome;
                return Text(nome ?? 'ninguém');
              },
            ),
          ),
        ),
      );
      expect(find.text('ninguém'), findsOneWidget);
      await sessao.entrar('geovana@exemplo.com', 'segredo123');
      await tester.pump();
      expect(find.text('Geovana'), findsOneWidget);
    });
  });

  group('Listagem e detalhe dos filmes', () {
    testWidgets('a lista mostra os filmes recebidos da API em ordem alfabética',
        (tester) async {
      await entrarEAbrirFilmes(tester);
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Interestelar'), findsOneWidget);
      expect(find.text('O Poderoso Chefão'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Interestelar')).dy,
        lessThan(tester.getTopLeft(find.text('O Poderoso Chefão')).dy),
      );
    });

    testWidgets('lista vazia apresenta a mensagem correspondente',
        (tester) async {
      await entrarEAbrirFilmes(tester, filmes: apiDeFilmes(corpo: []));
      expect(find.text('Nenhum filme ainda.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('erro da API mostra Tentar de novo e recupera a lista',
        (tester) async {
      var indisponivel = true;
      final cliente = MockClient((pedido) async {
        if (indisponivel) {
          throw http.ClientException('Failed to fetch');
        }
        return http.Response(jsonEncode(doisFilmes), 200);
      });
      await entrarEAbrirFilmes(tester, filmes: cliente);
      expect(find.text('Não consegui carregar os filmes'), findsOneWidget);
      expect(
        find.text('Não consegui falar com a API. O uvicorn está rodando?'),
        findsOneWidget,
      );
      indisponivel = false;
      await tester.tap(find.widgetWithText(FilledButton, 'Tentar de novo'));
      await tester.pumpAndSettle();
      expect(find.text('Interestelar'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsNothing);
    });

    testWidgets('enquanto a API responde, a tela mostra carregamento',
        (tester) async {
      final resposta = Completer<http.Response>();
      final sessao = sessaoDeMentira();
      await sessao.entrar('geovana@exemplo.com', 'segredo123');
      await tester.pumpWidget(
        appDeTeste(
          sessao,
          filmes: MockClient((pedido) => resposta.future),
        ),
      );
      await tester.tap(find.text('Ver meus filmes'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      resposta.complete(http.Response(jsonEncode(doisFilmes), 200));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Interestelar'), findsOneWidget);
    });

    testWidgets('tocar em um filme abre o detalhe e busca pelo id',
        (tester) async {
      await entrarEAbrirFilmes(tester);
      pedidos = 0;
      await tester.tap(find.text('Interestelar'));
      await tester.pumpAndSettle();
      expect(find.byType(FilmeScreen), findsOneWidget);
      expect(find.text('Christopher Nolan'), findsOneWidget);
      expect(find.text('Ficção Científica'), findsOneWidget);
      expect(find.text('169 minutos'), findsOneWidget);
      expect(find.text('Não assistido'), findsOneWidget);
      expect(pedidos, 1);
    });

    testWidgets('filme que não existe mostra o erro devolvido pela API',
        (tester) async {
      await entrarEAbrirFilmes(tester);
      Navigator.of(tester.element(find.byType(FilmesScreen)))
          .pushNamed(AppRoutes.filme, arguments: 99);
      await tester.pumpAndSettle();
      expect(find.byType(FilmeScreen), findsOneWidget);
      expect(find.text('Não consegui carregar o filme'), findsOneWidget);
      expect(find.text('Filme não encontrado.'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });

    testWidgets('abrir detalhe sem id volta para a lista, como no F5',
        (tester) async {
      await entrarEAbrirFilmes(tester);
      Navigator.of(tester.element(find.byType(FilmesScreen)))
          .pushNamed(AppRoutes.filme);
      await tester.pumpAndSettle();
      expect(find.byType(FilmeScreen), findsNothing);
      expect(find.byType(FilmesScreen), findsOneWidget);
    });
  });

  group('Repositório e service de filmes', () {
    test('repositório envia token e converte JSON em objetos Filme', () async {
      String? autorizacao;
      final cliente = MockClient((pedido) async {
        autorizacao = pedido.headers['Authorization'];
        return http.Response(jsonEncode(doisFilmes), 200);
      });
      final filmes = await FilmeRepository(cliente: cliente).listar('tk-123');
      expect(autorizacao, 'Bearer tk-123');
      expect(filmes, hasLength(2));
      expect(filmes.first, isA<Filme>());
      expect(filmes.first.titulo, 'O Poderoso Chefão');
      expect(filmes.last.assistido, isFalse);
    });

    test('repositório busca um filme pelo id e envia o token', () async {
      String? caminho;
      String? autorizacao;
      final cliente = MockClient((pedido) async {
        caminho = pedido.url.path;
        autorizacao = pedido.headers['Authorization'];
        return http.Response(jsonEncode(doisFilmes.last), 200);
      });
      final filme = await FilmeRepository(cliente: cliente).buscar('tk-123', 2);
      expect(caminho, '/filmes/2');
      expect(autorizacao, 'Bearer tk-123');
      expect(filme.titulo, 'Interestelar');
    });

    test('service recusa consulta sem sessão', () async {
      final sessao = sessaoDeMentira();
      final service = FilmeService(
        FilmeRepository(cliente: apiDeFilmes()),
        sessao,
      );
      await expectLater(
        service.listar(),
        throwsA(isA<ErroDeFilmes>()),
      );
    });

    test('service transforma a recusa da API em ErroDeFilmes', () async {
      final sessao = sessaoDeMentira();
      await sessao.entrar('geovana@exemplo.com', 'segredo123');
      final cliente = apiDeFilmes(
        status: 401,
        corpo: {'detail': 'Not authenticated'},
      );
      final service = FilmeService(FilmeRepository(cliente: cliente), sessao);
      await expectLater(
        service.listar(),
        throwsA(
          isA<ErroDeFilmes>().having(
            (erro) => erro.mensagem,
            'mensagem',
            'Not authenticated',
          ),
        ),
      );
    });
  });

  group('Persistência da sessão', () {
    test('entrar guarda o token no armazenamento local', () async {
      final sessao = sessaoDeMentira();
      await sessao.entrar('geovana@exemplo.com', 'segredo123');
      expect(await tokenGuardado(), 'token-da-geovana');
    });

    test('restaurar recupera usuário com token válido', () async {
      final sessao = sessaoDeMentira(
        guardado: {'token': 'token-da-geovana'},
      );
      pedidos = 0;
      await sessao.restaurar();
      expect(sessao.logado, isTrue);
      expect(sessao.usuario?.nome, 'Geovana');
      expect(pedidos, 1);
    });

    test('restaurar sem token não chama a API', () async {
      final sessao = sessaoDeMentira();
      pedidos = 0;
      await sessao.restaurar();
      expect(sessao.logado, isFalse);
      expect(pedidos, 0);
    });

    test('restaurar apaga token recusado pela API', () async {
      SharedPreferences.setMockInitialValues({'token': 'token-vencido'});
      final sessao = SessaoService(
        UsuarioRepository(
          cliente: MockClient(
            (_) async => http.Response(
              jsonEncode({'detail': 'Token inválido'}),
              401,
            ),
          ),
        ),
      );
      await sessao.restaurar();
      expect(sessao.logado, isFalse);
      expect(await tokenGuardado(), isNull);
    });

    test('sair apaga o token persistido', () async {
      final sessao = sessaoDeMentira(
        guardado: {'token': 'token-da-geovana'},
      );
      await sessao.restaurar();
      await sessao.sair();
      expect(sessao.logado, isFalse);
      expect(await tokenGuardado(), isNull);
    });

    test('entrar e sair notificam quem acompanha a sessão', () async {
      final sessao = sessaoDeMentira();
      var avisos = 0;
      sessao.addListener(() => avisos++);
      await sessao.entrar('geovana@exemplo.com', 'segredo123');
      expect(sessao.usuario?.nome, 'Geovana');
      expect(avisos, 1);
      await sessao.sair();
      expect(sessao.usuario, isNull);
      expect(avisos, 2);
    });
  });
}
