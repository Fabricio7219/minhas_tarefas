/// Modelo que representa um usuário do aplicativo.
///
/// Cada objeto Usuario corresponde a uma linha da tabela `usuarios`.
class Usuario {
  final int? id; // null enquanto o usuário ainda não foi salvo no banco
  final String nome;
  final String email;
  final String senhaHash; // nunca guardamos a senha "pura", só o hash

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
  });

  /// Converte o objeto em Map para salvar no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
    };
  }

  /// Cria um Usuario a partir de uma linha (Map) lida do SQLite.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senhaHash: map['senha_hash'] as String,
    );
  }
}
