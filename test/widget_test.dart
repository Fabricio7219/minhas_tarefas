import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:minhas_tarefas/models/tarefa.dart';
import 'package:minhas_tarefas/screens/login_screen.dart';
import 'package:minhas_tarefas/services/auth_service.dart';
import 'package:minhas_tarefas/utils/validadores.dart';

void main() {
  group('Validadores', () {
    test('e-mail vazio e inválido geram erro', () {
      expect(Validadores.email(''), 'Informe o e-mail');
      expect(Validadores.email('abc'), 'E-mail inválido');
      expect(Validadores.email('fulano@email.com'), isNull);
    });

    test('senha precisa de 6 caracteres', () {
      expect(Validadores.senha('123'), isNotNull);
      expect(Validadores.senha('123456'), isNull);
    });
  });

  test('Tarefa converte para Map e volta igual', () {
    final tarefa = Tarefa(
      id: 1,
      usuarioId: 7,
      titulo: 'Estudar Flutter',
      concluida: true,
      dataCriacao: '2026-11-03T10:00:00',
    );
    final copia = Tarefa.fromMap(tarefa.toMap());

    expect(tarefa.toMap()['concluida'], 1); // bool vira 1 no SQLite
    expect(copia.titulo, 'Estudar Flutter');
    expect(copia.concluida, isTrue);
  });

  test('Hash da senha não é a senha original', () {
    final hash = AuthService.gerarHash('123456');
    expect(hash, isNot('123456'));
    expect(hash.length, 64);
  });

  testWidgets('Login com campos vazios mostra mensagens de erro',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });
}
