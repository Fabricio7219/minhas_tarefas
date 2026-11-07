import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/tarefa_card.dart';

/// Tela principal: lista as tarefas do usuário logado (READ do CRUD)
/// e dá acesso a criar, editar, concluir e excluir.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A rota é protegida, então aqui sempre existe um usuário logado.
  final _usuario = AuthService.usuarioLogado!;

  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas(); // carrega a lista assim que a tela abre
  }

  /// READ - busca as tarefas no banco e redesenha a tela.
  Future<void> _carregarTarefas() async {
    final lista = await DatabaseService.listarTarefas(_usuario.id!);
    if (!mounted) return;
    setState(() {
      _tarefas = lista;
      _carregando = false;
    });
  }

  /// Abre o formulário. Sem tarefa = criar; com tarefa = editar.
  Future<void> _abrirFormulario([Tarefa? tarefa]) async {
    final salvou = await Navigator.pushNamed(
      context,
      Rotas.tarefaForm,
      arguments: tarefa,
    );
    // O formulário devolve true quando salvou algo.
    if (salvou == true) _carregarTarefas();
  }

  /// UPDATE - marca/desmarca a tarefa como concluída.
  Future<void> _marcarConcluida(Tarefa tarefa, bool? valor) async {
    await DatabaseService.atualizarTarefa(
      tarefa.copyWith(concluida: valor ?? false),
    );
    _carregarTarefas();
  }

  /// DELETE - pede confirmação e exclui a tarefa.
  Future<void> _excluir(Tarefa tarefa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await DatabaseService.deletarTarefa(tarefa.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa excluída!')),
    );
    _carregarTarefas();
  }

  /// LOGOUT - limpa a sessão e volta para o login apagando o histórico
  /// de telas (assim o "voltar" não retorna para a Home).
  void _sair() {
    AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, Rotas.login, (rota) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = _tarefas.where((t) => !t.concluida).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${_usuario.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
              ? const Center(
                  child: Text('Nenhuma tarefa ainda.\nToque no + para criar.',
                      textAlign: TextAlign.center),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '$pendentes pendente(s) de ${_tarefas.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _tarefas.length,
                        itemBuilder: (context, index) {
                          final tarefa = _tarefas[index];
                          return TarefaCard(
                            tarefa: tarefa,
                            onMarcar: (v) => _marcarConcluida(tarefa, v),
                            onEditar: () => _abrirFormulario(tarefa),
                            onExcluir: () => _excluir(tarefa),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova tarefa',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
