import 'package:flutter/material.dart';

import 'models/tarefa.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tarefa_form_screen.dart';
import 'services/auth_service.dart';

/// Nomes de todas as rotas (telas) do app num só lugar.
class Rotas {
  // '/' é a rota inicial padrão do Flutter, por isso o login usa ela.
  static const login = '/';
  static const cadastro = '/cadastro';
  static const home = '/home';
  static const tarefaForm = '/tarefa';

  /// Telas que só podem ser abertas por quem fez login.
  static const protegidas = [home, tarefaForm];

  /// Chamado pelo MaterialApp toda vez que usamos Navigator.pushNamed(...).
  ///
  /// É aqui que fica a PROTEÇÃO DE TELAS: se a rota é protegida e
  /// ninguém está logado, o usuário é mandado para o login.
  static Route<dynamic> gerarRota(RouteSettings settings) {
    if (protegidas.contains(settings.name) && !AuthService.estaLogado) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case cadastro:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case tarefaForm:
        // Se veio uma Tarefa nos argumentos é edição; se não, é criação.
        final tarefa = settings.arguments as Tarefa?;
        return MaterialPageRoute(
          builder: (_) => TarefaFormScreen(tarefa: tarefa),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
