import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    // Na edição, preenche os campos com os dados atuais.
    if (_editando) {
      _tituloController.text = widget.tarefa!.titulo;
      _descricaoController.text = widget.tarefa!.descricao;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      if (_editando) {
        // UPDATE
        await DatabaseService.atualizarTarefa(
          widget.tarefa!.copyWith(
            titulo: _tituloController.text.trim(),
            descricao: _descricaoController.text.trim(),
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
