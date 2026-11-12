import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../services/sessao_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario.nome),
            accountEmail: Text(usuario.email),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.person, size: 34)),
          ),
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Início'),
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.inicio)),
          ListTile(leading: const Icon(Icons.movie_outlined), title: const Text('Filmes'),
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.filmes)),
          ListTile(leading: const Icon(Icons.person_outline), title: const Text('Perfil'),
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.perfil)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout), title: const Text('Sair'),
            onTap: () async {
              await context.read<SessaoService>().sair();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (rota) => false);
            },
          ),
        ],
      ),
    );
  }
}
