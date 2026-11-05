import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/sessao_service.dart';
import 'login_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key, required this.sessao});
  final SessaoService sessao;

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late Future<Usuario> usuario;

  @override
  void initState() {
    super.initState();
    usuario = widget.sessao.usuarioLogado();
  }

  void sair() {
    widget.sessao.sair();
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => LoginScreen(sessao: widget.sessao)),
      (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Cinema Organizado'),
        actions: [IconButton(onPressed: sair, tooltip: 'Sair', icon: const Icon(Icons.logout))]),
      body: Center(child: FutureBuilder<Usuario>(
        future: usuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Não foi possível carregar sua conta.'),
              const SizedBox(height: 12),
              FilledButton(onPressed: sair, child: const Text('Voltar ao login')),
            ]);
          }
          final pessoa = snapshot.data!;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.account_circle_outlined, size: 64),
            const SizedBox(height: 12),
            Text('Olá, ${pessoa.nome}!', style: Theme.of(context).textTheme.headlineSmall),
            Text(pessoa.email),
            const SizedBox(height: 12),
            const Text('Login realizado com sucesso.'),
          ]);
        },
      )),
    );
  }
}
