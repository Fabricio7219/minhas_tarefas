/// Funções de validação usadas nos formulários.
///
/// Cada função devolve:
///  - null  -> campo válido
///  - texto -> mensagem de erro que aparece embaixo do campo
class Validadores {
  static String? obrigatorio(String? valor, String nomeCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $nomeCampo';
    }
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o e-mail';
    }
    // Regra simples: algo@algo.algo
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(valor.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? senha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Informe a senha';
    }
    if (valor.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
}
