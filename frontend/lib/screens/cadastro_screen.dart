import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../services/sessao_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}
class _CadastroScreenState extends State<CadastroScreen> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  bool carregando = false;
  String? erro;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    setState(() { carregando = true; erro = null; });
    try {
      await context.read<SessaoService>().cadastrar(nome.text, email.text, senha.text);
    } on ErroDeCadastro catch (e) {
      if (!mounted) return;
      setState(() { carregando = false; erro = e.mensagem; });
      return;
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.inicio, (rota) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Cinema Organizado')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Criar conta', textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(controller: nome, decoration: const InputDecoration(
                  labelText: 'Nome', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: email, keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: senha, obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha', helperText: 'Pelo menos 6 caracteres',
                      border: OutlineInputBorder())),
                if (erro != null) ...[
                  const SizedBox(height: 16),
                  Text(erro!, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: carregando ? null : cadastrar,
                  child: Text(carregando ? 'Cadastrando...' : 'Cadastrar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (rota) => false),
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
