import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'routes.dart';

void main() {
  // No Windows e no Linux o sqflite precisa do driver FFI (igual à Aula 23).
  // No Android/iOS não precisa fazer nada.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MinhasTarefasApp());
}

class MinhasTarefasApp extends StatelessWidget {
  const MinhasTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      // O app sempre começa no login (rota '/').
      initialRoute: Rotas.login,
      // Todas as rotas passam por aqui (inclui a proteção de telas).
      onGenerateRoute: Rotas.gerarRota,
    );
  }
}
