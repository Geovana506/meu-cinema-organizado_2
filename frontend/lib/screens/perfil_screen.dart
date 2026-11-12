import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sessao_service.dart';
import '../widgets/app_drawer.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario!;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      drawer: const AppDrawer(),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 38,
                  child: Icon(Icons.person, size: 42),
                ),
                const SizedBox(height: 18),
                Text(
                  usuario.nome,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(usuario.email),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
