import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filme.dart';
import '../services/filme_service.dart';
import '../widgets/app_drawer.dart';

class FilmeScreen extends StatefulWidget {
  const FilmeScreen({super.key, required this.filmeId});

  final int filmeId;

  @override
  State<FilmeScreen> createState() => _FilmeScreenState();
}

class _FilmeScreenState extends State<FilmeScreen> {
  late Future<Filme> filme;

  @override
  void initState() {
    super.initState();
    filme = context.read<FilmeService>().buscar(widget.filmeId);
  }

  void tentarDeNovo() {
    setState(() {
      filme = context.read<FilmeService>().buscar(widget.filmeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do filme')),
      drawer: const AppDrawer(),
      body: FutureBuilder<Filme>(
        future: filme,
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
                    const Text('Não consegui carregar o filme'),
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
          final item = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.movie_creation_outlined, size: 72),
              const SizedBox(height: 20),
              Text(
                item.titulo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              _CampoDetalhe(rotulo: 'Diretor', valor: item.diretor),
              _CampoDetalhe(rotulo: 'Ano', valor: '${item.ano}'),
              _CampoDetalhe(rotulo: 'Gênero', valor: item.genero),
              _CampoDetalhe(
                rotulo: 'Duração',
                valor: '${item.duracaoMinutos} minutos',
              ),
              _CampoDetalhe(
                rotulo: 'Situação',
                valor: item.assistido ? 'Assistido' : 'Não assistido',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CampoDetalhe extends StatelessWidget {
  const _CampoDetalhe({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(rotulo),
      subtitle: Text(valor),
    );
  }
}
