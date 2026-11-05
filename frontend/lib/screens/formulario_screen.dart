import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filme.dart';
import '../routes.dart';
import '../services/filme_service.dart';
import 'filmes_screen.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key, this.filme});

  final Filme? filme;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final chave = GlobalKey<FormState>();
  late final TextEditingController titulo;
  late final TextEditingController diretor;
  late final TextEditingController ano;
  late final TextEditingController genero;
  late final TextEditingController duracao;
  late bool assistido;
  bool salvando = false;
  String? erro;

  bool get editando => widget.filme != null;

  @override
  void initState() {
    super.initState();
    final filme = widget.filme;
    titulo = TextEditingController(text: filme?.titulo ?? '');
    diretor = TextEditingController(text: filme?.diretor ?? '');
    ano = TextEditingController(text: filme?.ano.toString() ?? '');
    genero = TextEditingController(text: filme?.genero ?? '');
    duracao = TextEditingController(
      text: filme?.duracaoMinutos.toString() ?? '',
    );
    assistido = filme?.assistido ?? false;
  }

  @override
  void dispose() {
    titulo.dispose();
    diretor.dispose();
    ano.dispose();
    genero.dispose();
    duracao.dispose();
    super.dispose();
  }

  String? validarTexto(String? valor, String campo, int limite) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe $campo';
    if (texto.length > limite) return '$campo deve ter até $limite caracteres';
    return null;
  }

  String? validarAno(String? valor) {
    final numero = int.tryParse(valor?.trim() ?? '');
    if (numero == null) return 'Informe um ano válido, só com números';
    if (numero < 1888 || numero > 2100) {
      return 'O ano precisa estar entre 1888 e 2100';
    }
    return null;
  }

  String? validarDuracao(String? valor) {
    final numero = int.tryParse(valor?.trim() ?? '');
    if (numero == null || numero <= 0 || numero > 1000) {
      return 'Informe uma duração entre 1 e 1000 minutos';
    }
    return null;
  }

  Future<void> salvar() async {
    if (!chave.currentState!.validate()) return;

    setState(() {
      salvando = true;
      erro = null;
    });

    try {
      final dados = {
        'titulo': titulo.text.trim(),
        'diretor': diretor.text.trim(),
        'ano': int.parse(ano.text.trim()),
        'genero': genero.text.trim(),
        'duracaoMinutos': int.parse(duracao.text.trim()),
        'assistido': assistido,
      };
      final service = context.read<FilmeService>();
      if (editando) {
        await service.atualizar(widget.filme!.id,
            titulo: dados['titulo'] as String,
            diretor: dados['diretor'] as String,
            ano: dados['ano'] as int,
            genero: dados['genero'] as String,
            duracaoMinutos: dados['duracaoMinutos'] as int,
            assistido: dados['assistido'] as bool);
      } else {
        await service.criar(
          titulo: dados['titulo'] as String,
          diretor: dados['diretor'] as String,
          ano: dados['ano'] as int,
          genero: dados['genero'] as String,
          duracaoMinutos: dados['duracaoMinutos'] as int,
          assistido: dados['assistido'] as bool,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ErroDeFilmes catch (e) {
      if (!mounted) return;
      setState(() {
        erro = e.mensagem;
        salvando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments == null && !editando) {
      // Um F5 perde os arguments. Nesse caso, não existe filme para editar.
      // A rota sem argumentos volta à listagem.
      return const FilmesScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar filme' : 'Novo filme')),
      body: Form(
        key: chave,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: titulo,
              maxLength: 150,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) => validarTexto(v, 'o título', 150),
            ),
            TextFormField(
              controller: diretor,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Diretor'),
              validator: (v) => validarTexto(v, 'o diretor', 120),
            ),
            TextFormField(
              controller: ano,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ano'),
              validator: validarAno,
            ),
            TextFormField(
              controller: genero,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Gênero'),
              validator: (v) => validarTexto(v, 'o gênero', 80),
            ),
            TextFormField(
              controller: duracao,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duração (minutos)',
              ),
              validator: validarDuracao,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Já assisti a este filme'),
              value: assistido,
              onChanged: salvando
                  ? null
                  : (valor) => setState(() => assistido = valor),
            ),
            if (erro != null) ...[
              const SizedBox(height: 12),
              Text(
                erro!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: salvando ? null : salvar,
              child: salvando
                  ? const CircularProgressIndicator()
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
