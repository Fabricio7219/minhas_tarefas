import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../utils/datas.dart';

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

  /// Escolhe cor, ícone e texto do aviso de prazo.
  /// Devolve null quando a tarefa não tem data de entrega.
  ({Color cor, IconData icone, String texto})? _avisoPrazo() {
    final dias = tarefa.diasRestantes();
    if (dias == null) return null;
    final data = Datas.formatar(tarefa.dataEntrega!);

    switch (tarefa.statusPrazo()) {
      case StatusPrazo.vencida:
        final atraso = -dias;
        return (
          cor: Colors.red,
          icone: Icons.error,
          texto: 'VENCIDA há $atraso dia(s) ($data)',
        );
      case StatusPrazo.venceHoje:
        return (
          cor: Colors.deepOrange,
          icone: Icons.warning,
          texto: 'URGENTE: vence hoje',
        );
      case StatusPrazo.proximo:
        return (
          cor: Colors.amber.shade800,
          icone: Icons.schedule,
          texto: dias == 1 ? 'Vence amanhã ($data)' : 'Vence em $dias dias ($data)',
        );
      case StatusPrazo.emDia:
        return (cor: Colors.green, icone: Icons.event, texto: 'Entrega: $data');
      case StatusPrazo.concluida:
        return (cor: Colors.grey, icone: Icons.check_circle, texto: 'Entrega: $data');
      case StatusPrazo.semPrazo:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aviso = _avisoPrazo();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // Contorno colorido conforme o prazo (sem prazo = contorno padrão).
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: aviso == null || tarefa.concluida
            ? BorderSide.none
            : BorderSide(color: aviso.cor, width: 2),
      ),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tarefa.descricao.isNotEmpty) Text(tarefa.descricao),
            if (aviso != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(aviso.icone, size: 16, color: aviso.cor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        aviso.texto,
                        style: TextStyle(
                          color: aviso.cor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
