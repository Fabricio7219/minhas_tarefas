/// Funções para trabalhar com datas no formato brasileiro.
class Datas {
  /// DateTime -> "aaaa-mm-dd" (formato salvo no banco).
  static String paraBanco(DateTime data) {
    return '${data.year}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';
  }

  /// "aaaa-mm-dd" -> "dd/mm/aaaa" (formato mostrado na tela).
  static String formatar(String dataBanco) {
    final d = DateTime.parse(dataBanco);
    return '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';
  }

  static String _doisDigitos(int n) => n.toString().padLeft(2, '0');
}
