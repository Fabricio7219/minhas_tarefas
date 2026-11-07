import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/usuario.dart';
import 'database_service.dart';

/// Erro de autenticação com uma mensagem amigável para mostrar na tela.
class AuthException implements Exception {
  final String mensagem;
  AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Cuida de cadastro, login, logout e de saber quem está logado.
///
/// A autenticação é LOCAL: os usuários ficam na tabela `usuarios` do SQLite
/// e a senha é guardada como hash SHA-256 (nunca a senha original).
class AuthService {
  // Usuário da sessão atual. null = ninguém logado.
  static Usuario? _usuarioLogado;

  static Usuario? get usuarioLogado => _usuarioLogado;
  static bool get estaLogado => _usuarioLogado != null;

  /// Transforma a senha em um hash SHA-256 (texto de 64 caracteres).
  static String gerarHash(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  /// Cadastra um novo usuário.
  /// Lança AuthException se o e-mail já estiver em uso.
  static Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();

    final existente =
        await DatabaseService.buscarUsuarioPorEmail(emailNormalizado);
    if (existente != null) {
      throw AuthException('Este e-mail já está cadastrado.');
    }

    await DatabaseService.inserirUsuario(
      Usuario(
        nome: nome.trim(),
        email: emailNormalizado,
        senhaHash: gerarHash(senha),
      ),
    );
  }

  /// Faz login. Lança AuthException se e-mail ou senha estiverem errados.
  static Future<void> login({
    required String email,
    required String senha,
  }) async {
    final usuario = await DatabaseService.buscarUsuarioPorEmail(
      email.trim().toLowerCase(),
    );

    // Mesma mensagem para os dois casos: não revela se o e-mail existe.
    if (usuario == null || usuario.senhaHash != gerarHash(senha)) {
      throw AuthException('E-mail ou senha inválidos.');
    }

    _usuarioLogado = usuario;
  }

  /// Encerra a sessão.
  static void logout() {
    _usuarioLogado = null;
  }
}
