import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';

/// Centraliza TODO o acesso ao banco SQLite.
///
/// As telas nunca escrevem SQL: elas chamam os métodos desta classe.
/// (Mesma ideia da classe SQLHelper vista na Aula 23.)
class DatabaseService {
  static const _nomeArquivo = 'minhas_tarefas.db';
  static const _versao = 1;

  // Guarda o banco já aberto para não abrir o arquivo toda hora.
  static Database? _banco;

  /// Retorna o banco aberto (abre na primeira chamada).
  static Future<Database> get banco async {
    _banco ??= await _abrirBanco();
    return _banco!;
  }

  static Future<Database> _abrirBanco() async {
    final pasta = await getDatabasesPath();
    final caminho = path.join(pasta, _nomeArquivo);
    debugPrint('Banco SQLite em: $caminho');

    return openDatabase(
      caminho,
      version: _versao,
      // Liga as chaves estrangeiras (no SQLite elas vêm desligadas).
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      // Executado só quando o banco ainda não existe.
      onCreate: _criarTabelas,
    );
  }

  static Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tarefas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        concluida INTEGER NOT NULL DEFAULT 0,
        data_criacao TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');
  }

  // ===================== USUÁRIOS =====================

  /// Insere um usuário e devolve o id gerado.
  static Future<int> inserirUsuario(Usuario usuario) async {
    final db = await banco;
    final dados = usuario.toMap()..remove('id'); // id é gerado pelo SQLite
    return db.insert('usuarios', dados);
  }

  /// Busca um usuário pelo e-mail. Retorna null se não existir.
  static Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final db = await banco;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ?', // o "?" evita SQL Injection
      whereArgs: [email],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return Usuario.fromMap(resultado.first);
  }

  // ===================== TAREFAS (CRUD) =====================

  /// CREATE - insere uma tarefa e devolve o id gerado.
  static Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await banco;
    final dados = tarefa.toMap()..remove('id');
    return db.insert('tarefas', dados);
  }

  /// READ - lista as tarefas de um usuário (pendentes primeiro, depois as mais novas).
  static Future<List<Tarefa>> listarTarefas(int usuarioId) async {
    final db = await banco;
    final resultado = await db.query(
      'tarefas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'concluida ASC, id DESC',
    );
    return resultado.map((linha) => Tarefa.fromMap(linha)).toList();
  }

  /// UPDATE - atualiza a tarefa e devolve quantas linhas foram alteradas.
  static Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await banco;
    return db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  /// DELETE - remove a tarefa pelo id.
  static Future<int> deletarTarefa(int id) async {
    final db = await banco;
    return db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
