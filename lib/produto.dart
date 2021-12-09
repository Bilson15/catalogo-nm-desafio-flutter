class Produto {
  String? _nome;
  double? _preco;
  String? _descricao;
  List<String>? _url;
  int? indexImage;

  Produto([this._nome, this._preco, this._descricao, this._url]);

  String? get nome {
    return _nome;
  }

  double? get preco {
    return _preco;
  }

  String? get descricao {
    return _descricao;
  }

  List<String>? get url {
    return _url;
  }

  set nome(String? pNome) {
    _nome = pNome;
  }

  set preco(double? pPreco) {
    _preco = pPreco;
  }

  set descricao(String? pDescricao) {
    _descricao = pDescricao;
  }

  set url(List<String>? pUrlImage) {
    _url = pUrlImage;
  }

  @override
  String toString() {
    return "Nome: $_nome, preco $_preco, descricao $_descricao, urlImage $url";
  }
}
