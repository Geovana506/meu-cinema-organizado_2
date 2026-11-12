import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filme.dart';
import '../routes.dart';
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
  String? erro;

  @override
  void initState() {
    super.initState();
    filme = context.read<FilmeService>().buscar(widget.filmeId);
  }

  void tentarDeNovo() {
    setState(() {
      erro = null;
      filme = context.read<FilmeService>().buscar(widget.filmeId);
    });
  }

  Future<void> editar(Filme item) async {
    final salvou = await Navigator.pushNamed(
      context,
      AppRoutes.formulario,
      arguments: item,
    );
    if (salvou == true && mounted) Navigator.pop(context, true);
  }

  Future<void> excluir(Filme item) async {
    final certeza = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir ${item.titulo}?'),
        content: const Text(
          'Tem certeza? O filme será removido do catálogo e não será possível desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (certeza != true || !mounted) return;
    try {
      await context.read<FilmeService>().excluir(item.id);
    } on ErroDeFilmes catch (e) {
      if (!mounted) return;
      setState(() => erro = e.mensagem);
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
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
                    const Icon(Icons.cloud_off_outlined, size: 56),
                    const SizedBox(height: 16),
                    const Text('Não consegui carregar o filme'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: tema.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: tema.colorScheme.surface.withValues(alpha: 0.7),
                      foregroundColor: tema.colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.movie_creation_outlined, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text(item.titulo,
                        style: tema.textTheme.headlineSmall?.copyWith(
                          color: tema.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    Text('${item.genero} · ${item.ano}',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onPrimaryContainer,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Column(
                  children: [
                    _LinhaDetalhe(icone: Icons.movie_filter_outlined,
                        rotulo: 'Gênero', valor: item.genero),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _LinhaDetalhe(icone: Icons.calendar_today_outlined,
                        rotulo: 'Ano', valor: '${item.ano}'),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _LinhaDetalhe(icone: Icons.person_outline,
                        rotulo: 'Diretor', valor: item.diretor),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _LinhaDetalhe(icone: Icons.schedule_outlined,
                        rotulo: 'Duração', valor: '${item.duracaoMinutos} minutos'),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _LinhaDetalhe(
                      icone: item.assistido ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      rotulo: 'Assistido',
                      valor: item.assistido ? 'Sim' : 'Não',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => editar(item),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => excluir(item),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                  ),
                ],
              ),
              if (erro != null) ...[
                const SizedBox(height: 16),
                Text(erro!, style: TextStyle(color: tema.colorScheme.error)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LinhaDetalhe extends StatelessWidget {
  const _LinhaDetalhe({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icone, color: tema.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(rotulo,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                )),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(valor,
                textAlign: TextAlign.end,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
