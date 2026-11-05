import 'package:flutter_test/flutter_test.dart';
import 'package:meu_cinema_organizado/main.dart';
import 'package:meu_cinema_organizado/repositories/usuario_repository.dart';
import 'package:meu_cinema_organizado/services/sessao_service.dart';

void main() {
  testWidgets('exibe a tela de login', (tester) async {
    final sessao = SessaoService(UsuarioRepository());
    await tester.pumpWidget(MeuCinemaApp(sessao: sessao));
    expect(find.text('Meu Cinema Organizado'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar uma conta'), findsOneWidget);
  });
}
