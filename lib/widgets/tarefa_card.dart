import 'package:flutter/material.dart';

import '../models/tarefa.dart';

/// Card que mostra uma tarefa na lista da tela inicial.
///
/// É Stateless: só exibe os dados e avisa a tela (via callbacks)
/// quando o usuário marca, edita ou exclui.
class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final ValueChanged<bool?> onMarcar;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onMarcar,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Checkbox(value: tarefa.concluida, onChanged: onMarcar),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            // Risca o título quando a tarefa está concluída.
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
            color: tarefa.concluida ? Colors.grey : null,
          ),
        ),
        subtitle: tarefa.descricao.isEmpty ? null : Text(tarefa.descricao),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar',
              onPressed: onEditar,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Excluir',
              onPressed: onExcluir,
            ),
          ],
        ),
      ),
    );
  }
}
