import 'package:flutter_test/flutter_test.dart';
import 'package:meu_cinema_organizado/main.dart';
import 'package:meu_cinema_organizado/repositories/usuario_repository.dart';
import 'package:meu_cinema_organizado/services/sessao_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('apresenta a tela de login do Meu Cinema Organizado', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SessaoService(UsuarioRepository()),
        child: const MeuCinemaApp(),
      ),
    );
    expect(find.text('Meu Cinema Organizado'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar uma conta'), findsOneWidget);
  });
}
