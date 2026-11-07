import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/auth_service.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave do formulário: usada para chamar validate().
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    // Libera os controllers quando a tela é destruída.
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    // 1) Valida os campos. Se algum estiver errado, para aqui.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      // 2) Tenta fazer login no AuthService.
      await AuthService.login(
        email: _emailController.text,
        senha: _senhaController.text,
      );
      if (!mounted) return;
      // 3) Deu certo: vai para a Home e remove o login da pilha
      //    (assim o botão "voltar" não volta para o login).
      Navigator.pushReplacementNamed(context, Rotas.home);
    } on AuthException catch (e) {
      _mostrarMensagem(e.mensagem);
    } catch (e) {
      _mostrarMensagem('Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.checklist, size: 80, color: Colors.indigo),
                const SizedBox(height: 8),
                const Text(
                  'Minhas Tarefas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                CampoTexto(
                  controller: _emailController,
                  label: 'E-mail',
                  icone: Icons.email,
                  teclado: TextInputType.emailAddress,
                  validator: Validadores.email,
                ),
                CampoTexto(
                  controller: _senhaController,
                  label: 'Senha',
                  icone: Icons.lock,
                  senha: true,
                  validator: (v) => Validadores.obrigatorio(v, 'a senha'),
                ),
                ElevatedButton(
                  onPressed: _carregando ? null : _entrar,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, Rotas.cadastro),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
