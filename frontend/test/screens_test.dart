import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meu_cinema_organizado/main.dart';
import 'package:meu_cinema_organizado/repositories/usuario_repository.dart';
import 'package:meu_cinema_organizado/routes.dart';
import 'package:meu_cinema_organizado/screens/cadastro_screen.dart';
import 'package:meu_cinema_organizado/screens/filmes_screen.dart';
import 'package:meu_cinema_organizado/screens/inicio_screen.dart';
import 'package:meu_cinema_organizado/screens/login_screen.dart';
import 'package:meu_cinema_organizado/screens/perfil_screen.dart';
import 'package:meu_cinema_organizado/services/sessao_service.dart';

int pedidos = 0;

SessaoService sessaoDeMentira() {
  SharedPreferences.setMockInitialValues({});
  final cliente = MockClient((pedido) async {
    pedidos++;
    if (pedido.url.path == '/usuarios/login') {
      if (pedido.bodyFields['password'] == 'segredo123') {
        return http.Response(
          jsonEncode({'access_token': 'token-da-geovana', 'token_type': 'bearer'}),
          200,
        );
      }
      return http.Response(jsonEncode({'detail': 'E-mail ou senha incorretos'}), 401);
    }

    if (pedido.url.path == '/usuarios/eu' &&
        pedido.headers['Authorization'] == 'Bearer token-da-geovana') {
      return http.Response(
        jsonEncode({'id': 1, 'nome': 'Geovana', 'email': 'geovana@exemplo.com'}),
        200,
      );
    }

    return http.Response(jsonEncode({'detail': 'Não autenticado'}), 401);
  });

  return SessaoService(UsuarioRepository(cliente: cliente));
  test('entrar guarda o token no armazenamento local', () async {
    final sessao = sessaoDeMentira();
    await sessao.entrar('geovana@exemplo.com', 'segredo123');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), 'token-da-geovana');
  });

  test('restaurar recupera usuário quando o token guardado ainda vale', () async {
    SharedPreferences.setMockInitialValues({'token': 'token-da-geovana'});
    final sessao = SessaoService(UsuarioRepository(
      cliente: MockClient((pedido) async {
        expect(pedido.url.path, '/usuarios/eu');
        expect(pedido.headers['Authorization'], 'Bearer token-da-geovana');
        return http.Response(
          jsonEncode({'id': 1, 'nome': 'Geovana', 'email': 'geovana@exemplo.com'}),
          200,
        );
      }),
    ));
    await sessao.restaurar();
    expect(sessao.logado, isTrue);
    expect(sessao.usuario?.nome, 'Geovana');
  });

  test('restaurar apaga token recusado pela API', () async {
    SharedPreferences.setMockInitialValues({'token': 'token-vencido'});
    final sessao = SessaoService(UsuarioRepository(
      cliente: MockClient((_) async =>
        http.Response(jsonEncode({'detail': 'Token inválido'}), 401)),
    ));
    await sessao.restaurar();
    final prefs = await SharedPreferences.getInstance();
    expect(sessao.logado, isFalse);
    expect(prefs.getString('token'), isNull);
  });

  test('restaurar preserva token se API estiver indisponível', () async {
    SharedPreferences.setMockInitialValues({'token': 'token-da-geovana'});
    final sessao = SessaoService(UsuarioRepository(
      cliente: MockClient((_) async => throw Exception('sem conexão')),
    ));
    await sessao.restaurar();
    final prefs = await SharedPreferences.getInstance();
    expect(sessao.logado, isFalse);
    expect(prefs.getString('token'), 'token-da-geovana');
  });

  test('sair remove o token persistido', () async {
    SharedPreferences.setMockInitialValues({'token': 'token-da-geovana'});
    final sessao = sessaoDeMentira();
    await sessao.sair();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(sessao.logado, isFalse);
  });

}

Widget appDeTeste(SessaoService sessao) {
  return ChangeNotifierProvider.value(value: sessao, child: const MeuCinemaApp());
}

Future<void> preencherEEntrar(WidgetTester tester, String senha) async {
  await tester.enterText(find.byType(TextField).at(0), 'geovana@exemplo.com');
  await tester.enterText(find.byType(TextField).at(1), senha);
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.pumpAndSettle();
}

Future<void> abrirMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login apresenta os campos e o acesso ao cadastro', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar uma conta'), findsOneWidget);
  });

  testWidgets('cadastro apresenta nome, e-mail e senha', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => sessaoDeMentira(),
        child: const MaterialApp(home: CadastroScreen()),
      ),
    );
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Cadastrar'), findsOneWidget);
  });

  testWidgets('login correto abre início e carrega o usuário', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    await preencherEEntrar(tester, 'segredo123');
    expect(find.byType(InicioScreen), findsOneWidget);
    expect(find.text('Olá, Geovana!'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('senha incorreta mantém a pessoa no login', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    await preencherEEntrar(tester, 'senha-errada');
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('cadastro abre pela rota nomeada', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    expect(find.byType(CadastroScreen), findsOneWidget);
  });

  testWidgets('rota protegida mostra login sem sessão', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    Navigator.of(tester.element(find.byType(LoginScreen))).pushNamed(AppRoutes.filmes);
    await tester.pumpAndSettle();
    expect(find.byType(FilmesScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('menu mostra nome e e-mail da pessoa autenticada', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    await preencherEEntrar(tester, 'segredo123');
    await abrirMenu(tester);
    final drawer = find.byType(Drawer);
    expect(find.descendant(of: drawer, matching: find.text('Geovana')), findsOneWidget);
    expect(
      find.descendant(of: drawer, matching: find.text('geovana@exemplo.com')),
      findsOneWidget,
    );
  });

  testWidgets('menu navega para o perfil', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    await preencherEEntrar(tester, 'segredo123');
    await abrirMenu(tester);
    await tester.tap(find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Perfil'),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(PerfilScreen), findsOneWidget);
    expect(find.text('geovana@exemplo.com'), findsOneWidget);
  });

  testWidgets('menu navega para a tela de filmes', (tester) async {
    await tester.pumpWidget(appDeTeste(sessaoDeMentira()));
    await preencherEEntrar(tester, 'segredo123');
    await abrirMenu(tester);
    await tester.tap(find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Filmes'),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(FilmesScreen), findsOneWidget);
  });

  testWidgets('Sair apaga sessão e limpa histórico de navegação', (tester) async {
    final sessao = sessaoDeMentira();
    await tester.pumpWidget(appDeTeste(sessao));
    await preencherEEntrar(tester, 'segredo123');
    await tester.tap(find.text('Ver meus filmes'));
    await tester.pumpAndSettle();
    await abrirMenu(tester);
    await tester.tap(find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Sair'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(FilmesScreen), findsNothing);
    expect(sessao.logado, isFalse);
    expect(Navigator.of(tester.element(find.byType(LoginScreen))).canPop(), isFalse);
  });

  testWidgets('watch atualiza a interface quando o service avisa', (tester) async {
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

  test('service recusa campos vazios sem chamar a API', () async {
    final sessao = sessaoDeMentira();
    pedidos = 0;
    await expectLater(sessao.entrar('', ''), throwsA(isA<ErroDeLogin>()));
    expect(pedidos, 0);
    expect(sessao.logado, isFalse);
  });

  test('entrar e sair alteram sessão e notificam ouvintes', () async {
    final sessao = sessaoDeMentira();
    var avisos = 0;
    sessao.addListener(() => avisos++);
    await sessao.entrar('geovana@exemplo.com', 'segredo123');
    expect(sessao.token, 'token-da-geovana');
    expect(sessao.usuario?.nome, 'Geovana');
    expect(avisos, 1);
    sessao.sair();
    expect(sessao.logado, isFalse);
    expect(sessao.usuario, isNull);
    expect(avisos, 2);
  });
}
