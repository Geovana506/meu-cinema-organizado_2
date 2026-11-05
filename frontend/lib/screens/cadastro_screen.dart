import 'package:flutter/material.dart';

import '../services/sessao_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key, required this.sessao});
  final SessaoService sessao;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  bool carregando = false;
  String? erro;
  bool sucesso = false;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    setState(() { carregando = true; erro = null; sucesso = false; });
    try {
      await widget.sessao.cadastrar(nome.text, email.text, senha.text);
      if (mounted) setState(() => sucesso = true);
    } on ErroDeLogin catch (e) {
      if (mounted) setState(() => erro = e.mensagem);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
          child: Column(children: [
            TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: senha, obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha', helperText: 'Pelo menos 6 caracteres', border: OutlineInputBorder())),
            if (erro != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(erro!, style: const TextStyle(color: Colors.red))),
            if (sucesso) const Padding(padding: EdgeInsets.only(top: 12),
              child: Text('Cadastro realizado! Agora você já pode entrar.')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: carregando ? null : cadastrar,
              child: carregando ? const CircularProgressIndicator() : const Text('Cadastrar'))),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Já tenho conta')),
          ]),
        ),
      )),
    );
  }
}
