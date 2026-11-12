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
  final busca = TextEditingController();
  String situacao = 'Todos';

  @override
  void initState() {
    super.initState();
    filmes = context.read<FilmeService>().listar();
    busca.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  void tentarDeNovo() {
    setState(() {
      filmes = context.read<FilmeService>().listar();
    });
  }

  Future<void> novoFilme() async {
    final salvou = await Navigator.pushNamed(
      context,
      AppRoutes.formulario,
      arguments: true,
    );
    if (salvou == true && mounted) tentarDeNovo();
  }

  Future<void> abrirFilme(int id) async {
    final alterou = await Navigator.pushNamed(
      context,
      AppRoutes.filme,
      arguments: id,
    );
    if (alterou == true && mounted) tentarDeNovo();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus filmes'),
        actions: [
          IconButton(
            tooltip: 'Novo filme',
            onPressed: novoFilme,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novoFilme,
        icon: const Icon(Icons.add),
        label: const Text('Novo filme'),
      ),
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
                    const Icon(Icons.cloud_off_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text('Não consegui carregar os filmes',
                        style: tema.textTheme.titleMedium),
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

          final lista = [...(snapshot.data ?? <Filme>[])];
          lista.sort((a, b) => a.titulo.toLowerCase().compareTo(
                b.titulo.toLowerCase(),
              ));
          final termo = busca.text.trim().toLowerCase();
          final resultado = lista.where((filme) {
            final correspondeBusca = termo.isEmpty ||
                filme.titulo.toLowerCase().contains(termo) ||
                filme.diretor.toLowerCase().contains(termo);
            final correspondeSituacao = situacao == 'Todos' ||
                (situacao == 'Assistidos' && filme.assistido) ||
                (situacao == 'Não assistidos' && !filme.assistido);
            return correspondeBusca && correspondeSituacao;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              Text('Seu catálogo pessoal',
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 4),
              Text('Encontre e organize os filmes da sua coleção.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: busca,
                decoration: InputDecoration(
                  hintText: 'Buscar por título ou diretor',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: busca.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          onPressed: () => busca.clear(),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filtro in ['Todos', 'Assistidos', 'Não assistidos'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: situacao == filtro,
                          onSelected: (_) => setState(() => situacao = filtro),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (lista.isEmpty)
                _EstadoCatalogo(
                  icone: Icons.movie_filter_outlined,
                  titulo: 'Nenhum filme por aqui ainda',
                  descricao: 'Comece adicionando o primeiro filme ao seu catálogo.',
                  acao: FilledButton.icon(
                    onPressed: novoFilme,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar primeiro filme'),
                  ),
                )
              else if (resultado.isEmpty)
                _EstadoCatalogo(
                  icone: Icons.search_off,
                  titulo: 'Nenhum resultado',
                  descricao: 'Não encontramos filmes com essa busca ou filtro.',
                  acao: OutlinedButton(
                    onPressed: () => setState(() {
                      busca.clear();
                      situacao = 'Todos';
                    }),
                    child: const Text('Limpar filtros'),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Text('Filmes', style: tema.textTheme.titleMedium),
                    const Spacer(),
                    Text('${resultado.length} ${resultado.length == 1 ? 'filme' : 'filmes'}',
                        style: tema.textTheme.labelMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                for (final filme in resultado)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: tema.colorScheme.primaryContainer,
                          foregroundColor: tema.colorScheme.onPrimaryContainer,
                          child: const Icon(Icons.movie_outlined),
                        ),
                        title: Text(filme.titulo,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('${filme.genero} · ${filme.ano}\n${filme.diretor}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          filme.assistido
                              ? Icons.check_circle
                              : Icons.schedule_outlined,
                          color: filme.assistido
                              ? tema.colorScheme.primary
                              : tema.colorScheme.onSurfaceVariant,
                          semanticLabel:
                              filme.assistido ? 'Assistido' : 'Não assistido',
                        ),
                        onTap: () => abrirFilme(filme.id),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EstadoCatalogo extends StatelessWidget {
  const _EstadoCatalogo({
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: tema.colorScheme.primaryContainer,
            foregroundColor: tema.colorScheme.onPrimaryContainer,
            child: Icon(icone, size: 32),
          ),
          const SizedBox(height: 18),
          Text(titulo, style: tema.textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(descricao,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center),
          if (acao != null) ...[
            const SizedBox(height: 20),
            acao!,
          ],
        ],
      ),
    );
  }
}
