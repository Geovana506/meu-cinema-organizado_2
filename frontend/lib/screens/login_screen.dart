import 'package:flutter/material.dart';

import '../services/sessao_service.dart';
import 'cadastro_screen.dart';
import 'inicio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.sessao});
  final SessaoService sessao;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final senha = TextEditingController();
  bool carregando = false;
  String? erro;

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    setState(() { carregando = true; erro = null; });
    try {
      await widget.sessao.entrar(email.text, senha.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => InicioScreen(sessao: widget.sessao)),
      );
    } on ErroDeLogin catch (e) {
      if (mounted) setState(() => erro = e.mensagem);
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_creation_outlined, size: 64),
                const SizedBox(height: 12),
                Text('Meu Cinema Organizado', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 28),
                TextField(controller: email, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: senha, obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
                if (erro != null) Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(erro!, style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: FilledButton(
                  onPressed: carregando ? null : entrar,
                  child: carregando ? const CircularProgressIndicator() : const Text('Entrar'),
                )),
                TextButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CadastroScreen(sessao: widget.sessao))),
                  child: const Text('Criar uma conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
