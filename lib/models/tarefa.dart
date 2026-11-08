/// Situação da tarefa em relação ao prazo de entrega.
enum StatusPrazo {
  semPrazo, // não tem data de entrega
  emDia, // falta 3 dias ou mais
  proximo, // falta 1 ou 2 dias
  venceHoje, // a entrega é hoje (urgente)
  vencida, // a data já passou
  concluida, // já foi feita, então o prazo não importa mais
}

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
  final String? dataEntrega; // "aaaa-mm-dd" ou null quando não tem prazo

  Tarefa({
    this.id,
    required this.usuarioId,
    required this.titulo,
    this.descricao = '',
    this.concluida = false,
    required this.dataCriacao,
    this.dataEntrega,
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
      'data_entrega': dataEntrega,
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
      dataEntrega: map['data_entrega'] as String?,
    );
  }

  /// Cria uma cópia da tarefa trocando só os campos informados.
  /// Útil para marcar/desmarcar como concluída.
  Tarefa copyWith({String? titulo, String? descricao, bool? concluida}) {
    return Tarefa(
      id: id,
      usuarioId: usuarioId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      dataCriacao: dataCriacao,
      dataEntrega: dataEntrega,
    );
  }

  /// Quantos dias faltam para a entrega.
  /// 0 = hoje | negativo = atrasada | null = sem data.
  int? diasRestantes([DateTime? agora]) {
    if (dataEntrega == null) return null;
    final hoje = agora ?? DateTime.now();
    final entrega = DateTime.parse(dataEntrega!);
    // Comparamos só as datas (sem hora), em UTC para a conta ser exata.
    final diaEntrega = DateTime.utc(entrega.year, entrega.month, entrega.day);
    final diaHoje = DateTime.utc(hoje.year, hoje.month, hoje.day);
    return diaEntrega.difference(diaHoje).inDays;
  }

  /// Classifica a tarefa pelo prazo (usado para escolher a cor na lista).
  StatusPrazo statusPrazo([DateTime? agora]) {
    if (concluida) return StatusPrazo.concluida;
    final dias = diasRestantes(agora);
    if (dias == null) return StatusPrazo.semPrazo;
    if (dias < 0) return StatusPrazo.vencida;
    if (dias == 0) return StatusPrazo.venceHoje;
    if (dias <= 2) return StatusPrazo.proximo;
    return StatusPrazo.emDia;
  }
}
