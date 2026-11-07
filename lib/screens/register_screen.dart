import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await AuthService.cadastrar(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Faça login.')),
      );
      // Volta para a tela de login.
      Navigator.pop(context);
    } on AuthException catch (e) {
      // Ex.: "Este e-mail já está cadastrado."
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTexto(
                controller: _nomeController,
                label: 'Nome',
                icone: Icons.person,
                validator: (v) => Validadores.obrigatorio(v, 'o nome'),
              ),
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
                validator: Validadores.senha,
              ),
              CampoTexto(
                controller: _confirmarController,
                label: 'Confirmar senha',
                icone: Icons.lock_outline,
                senha: true,
                validator: (v) {
                  if (v != _senhaController.text) {
                    return 'As senhas não conferem';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _carregando ? null : _cadastrar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
