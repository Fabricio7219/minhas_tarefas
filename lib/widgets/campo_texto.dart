import 'package:flutter/material.dart';

/// Campo de texto padrão do app, reaproveitado em todos os formulários.
///
/// É um TextFormField (e não TextField) porque ele aceita `validator`,
/// que é usado pelo Form para validar os campos.
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icone;
  final bool senha;
  final TextInputType teclado;
  final int maxLinhas;
  final String? Function(String?)? validator;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.label,
    this.icone,
    this.senha = false,
    this.teclado = TextInputType.text,
    this.maxLinhas = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: senha, // esconde o texto (para senhas)
        keyboardType: teclado,
        maxLines: senha ? 1 : maxLinhas,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icone != null ? Icon(icone) : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
