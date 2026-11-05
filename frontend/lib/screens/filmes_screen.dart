import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filme.dart';
import '../routes.dart';
import '../services/filme_service.dart';
import '../widgets/app_drawer.dart';

class FilmesScreen extends StatefulWidget {
  const FilmesScreen({super.key});

  @override
  State<FilmesScreen> createState() => _FilmesScreenState();
}

class _FilmesScreenState extends State<FilmesScreen> {
  late Future<List<Filme>> filmes;

  @override
  void initState() {
    super.initState();
    filmes = context.read<FilmeService>().listar();
  }

  void tentarDeNovo() {
    setState(() {
      filmes = context.read<FilmeService>().listar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus filmes')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Filme>>(
        future: filmes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56),
                    const SizedBox(height: 16),
                    const Text('Não consegui carregar os filmes'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: tentarDeNovo,
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
            );
          }

          final lista = [...(snapshot.data ?? <Filme>[])];
          lista.sort((a, b) => a.titulo.toLowerCase().compareTo(
                b.titulo.toLowerCase(),
              ));
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhum filme ainda.'));
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final filme = lista[i];
              return ListTile(
                leading: const Icon(Icons.movie_outlined),
                title: Text(filme.titulo),
                subtitle: Text('${filme.ano} • ${filme.diretor}'),
                trailing: Icon(
                  filme.assistido ? Icons.check_circle : Icons.schedule,
                  semanticLabel: filme.assistido ? 'Assistido' : 'Não assistido',
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.filme,
                  arguments: filme.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
