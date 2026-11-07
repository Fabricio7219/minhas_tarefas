/// Modelo que representa uma tarefa.
///
/// Cada tarefa pertence a um usuário (campo usuarioId), assim cada pessoa
/// só enxerga as próprias tarefas.
class Tarefa {
  final int? id; // null enquanto a tarefa ainda não foi salva
  final int usuarioId;
  final String titulo;
  final String descricao;
  final bool concluida;
  final String dataCriacao; // guardada como texto no formato ISO 8601

  Tarefa({
    this.id,
    required this.usuarioId,
    required this.titulo,
    this.descricao = '',
    this.concluida = false,
    required this.dataCriacao,
  });

  /// Converte o objeto em Map para salvar no SQLite.
  /// O SQLite não tem tipo booleano, então salvamos 1 (true) ou 0 (false).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
      'data_criacao': dataCriacao,
    };
  }

  /// Cria uma Tarefa a partir de uma linha (Map) lida do SQLite.
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      titulo: map['titulo'] as String,
      descricao: (map['descricao'] ?? '') as String,
      concluida: map['concluida'] == 1,
      dataCriacao: map['data_criacao'] as String,
    );
  }

  /// Cria uma cópia da tarefa trocando só os campos informados.
  /// Útil na edição e para marcar/desmarcar como concluída.
  Tarefa copyWith({String? titulo, String? descricao, bool? concluida}) {
    return Tarefa(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      dataCriacao: dataCriacao,
    );
  }
}
