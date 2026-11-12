import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';
import '../widgets/app_drawer.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario!;

    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.waving_hand_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Olá, ${usuario.nome}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(usuario.email),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.filmes),
              icon: const Icon(Icons.movie_outlined),
              label: const Text('Ver meus filmes'),
            ),
          ],
        ),
      ),
    );
  }
}
