import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/datas.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';

/// Formulário usado tanto para CRIAR quanto para EDITAR uma tarefa.
class TarefaFormScreen extends StatefulWidget {
  /// null = nova tarefa | preenchida = edição
  final Tarefa? tarefa;

  const TarefaFormScreen({super.key, this.tarefa});

  @override
  State<TarefaFormScreen> createState() => _TarefaFormScreenState();
}

class _TarefaFormScreenState extends State<TarefaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _salvando = false;
  String? _dataEntrega; // "aaaa-mm-dd" ou null (sem prazo)

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    // Na edição, preenche os campos com os dados atuais.
    if (_editando) {
      _tituloController.text = widget.tarefa!.titulo;
      _descricaoController.text = widget.tarefa!.descricao;
      _dataEntrega = widget.tarefa!.dataEntrega;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  /// Abre o calendário para escolher a data de entrega.
  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate:
          _dataEntrega != null ? DateTime.parse(_dataEntrega!) : hoje,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Data de entrega',
    );
    if (!mounted) return;
    // escolhida fica null se o usuário cancelar o calendário.
    if (escolhida != null) {
      setState(() => _dataEntrega = Datas.paraBanco(escolhida));
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      if (_editando) {
        // UPDATE - monta a tarefa com os dados novos mantendo id, dono,
        // situação e data de criação da tarefa original.
        final original = widget.tarefa!;
        await DatabaseService.atualizarTarefa(
          Tarefa(
            id: original.id,
            usuarioId: original.usuarioId,
            titulo: _tituloController.text.trim(),
            descricao: _descricaoController.text.trim(),
            concluida: original.concluida,
            dataCriacao: original.dataCriacao,
            dataEntrega: _dataEntrega,
          ),
        );
      } else {
        // CREATE
        await DatabaseService.inserirTarefa(
          Tarefa(
            usuarioId: AuthService.usuarioLogado!.id!,
            titulo: _tituloController.text.trim(),
            descricao: _descricaoController.text.trim(),
            dataCriacao: DateTime.now().toIso8601String(),
            dataEntrega: _dataEntrega,
          ),
        );
      }
      if (!mounted) return;
      // Volta para a Home devolvendo true ("salvei, pode recarregar").
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTexto(
                controller: _tituloController,
                label: 'Título',
                icone: Icons.title,
                validator: (v) => Validadores.obrigatorio(v, 'o título'),
              ),
              CampoTexto(
                controller: _descricaoController,
                label: 'Descrição (opcional)',
                icone: Icons.notes,
                maxLinhas: 3,
              ),
              // Campo da data de entrega (opcional).
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(
                    _dataEntrega == null
                        ? 'Sem data de entrega'
                        : 'Entregar até ${Datas.formatar(_dataEntrega!)}',
                  ),
                  subtitle: const Text('Toque para escolher a data'),
                  onTap: _escolherData,
                  // Botão para tirar a data, só aparece quando tem data.
                  trailing: _dataEntrega == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Remover data',
                          onPressed: () => setState(() => _dataEntrega = null),
                        ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: const Icon(Icons.save),
                label: Text(_editando ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
