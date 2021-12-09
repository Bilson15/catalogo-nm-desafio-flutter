import 'dart:ui';

import 'package:desafio_flutter/view/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:desafio_flutter/view/page_product.dart';
import 'package:desafio_flutter/produto.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final color = const Color.fromRGBO(4, 4, 145, 1.0);
  final color1 = const Color.fromRGBO(0, 207, 128, 1);
  final ScrollController _scrollController = ScrollController();

  List<Produto> produtos = [];

  String _userName = "";

  var prefs;

  String _pesquisa = "";
  int _qtdfim = 25;
  int _qtdInicio = 0;

  Future<List?> _getProducts() async {
    produtos.clear();
    List list = [];

    http.Response response;
    String ps = "ft=$_pesquisa";

    response = await http.get(Uri.parse(
        "https://novomundo.vtexcommercestable.com.br/api/catalog_system/pub/products/search?$ps&_from=$_qtdInicio&_to=$_qtdfim"));
    list = json.decode(response.body);

    for (Map l in list) {
      Produto p = new Produto();
      p.nome = l["productName"];
      p.preco = l["items"][0]["sellers"][0]["commertialOffer"]["ListPrice"];
      p.descricao = l["metaTagDescription"];
      p.url = [];
      for (Map i in l["items"][0]["images"]) {
        p.url!.add(i["imageUrl"]);
      }
      p.indexImage = 0;
      produtos.add(p);
    }

    return produtos;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  void _pageController() {
    _qtdInicio = _qtdfim + 1;
    _qtdfim += 25;

    _getProducts();
    setState(() {});
  }

  _loadUserInfo() async {
    if (!mounted) {
      return;
    }

    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _userName = prefs.getString('user.name') ?? "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20.0,
            backgroundColor: Colors.transparent,
            title: ImageIcon(
              const AssetImage("assets/logo-azul.png"),
              color: color1,
              size: 80.0,
            ),
            centerTitle: true,
          ),
          backgroundColor: color,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        left: 30.0, right: 30.0, bottom: 5.0),
                    child: const Center(
                      child: Text(
                        "Bem vindo a ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Image.network(
                    "https://novomundo.vtexassets.com/arquivos/v2-logo-novo-mundo.png?v=20211118192653",
                    scale: 1.8,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Text(
                        "${_userName.split(" ")[0] + " " + _userName.split(" ")[1]}!",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 240.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const LoginPage()));
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        titleSpacing: 50.0,
        backgroundColor: color,
        title: Image.network(
            "https://novomundo.vtexassets.com/arquivos/v2-logo-novo-mundo.png?v=20211118192653"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                setState(() {
                  _qtdfim = 25;
                  _qtdInicio = 0;
                  _pesquisa = "";
                });
              },
              icon: const Icon(Icons.replay))
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color),
                  ),
                  icon: Icon(
                    Icons.search,
                    color: color,
                  ),
                  labelText: "Pesquisar",
                  labelStyle: TextStyle(color: color),
                  border: const OutlineInputBorder()),
              style: TextStyle(color: color, fontSize: 15.0),
              textAlign: TextAlign.center,
              cursorColor: color,
              onSubmitted: (text) {
                setState(() {
                  _pesquisa = text;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getProducts(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeWidth: 5.0,
                      ),
                    );
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        //margin: EdgeInsets.only(left: 15.0),
                        child: Center(
                          child: Text(
                            "Não foi encontrado nem um produto",
                            style: TextStyle(
                              color: color,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return _createCardProducts(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        child: const Icon(
          Icons.arrow_upward,
          color: Colors.white,
        ),
        onPressed: () {
          _scrollUp();
        },
      ),
    );
  }

  void _scrollUp() {
    const double start = 0;

    _scrollController.animateTo(start,
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
  }

  Widget _createCardProducts(context, snapshot) {
    return Stack(
      children: [
        OrientationBuilder(builder: (context, orientation) {
          return LazyLoadScrollView(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        orientation == Orientation.portrait ? 1 : 2),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: Card(
                            shape: Border(
                                bottom: BorderSide(color: color, width: 5.0)),
                            margin:
                                const EdgeInsets.fromLTRB(10.5, 0.0, 10.5, 0.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.0, bottom: 20.0),
                                ),
                                FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: snapshot.data[index].url[0],
                                  fit: BoxFit.cover,
                                  height: 180,
                                ),
                                Text(
                                  snapshot.data[index].nome,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: const TextStyle(
                                      fontSize: 20.0, wordSpacing: 2.0),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 15.0),
                                ),
                                Text(
                                  "R\$ " +
                                      snapshot.data[index].preco
                                          .toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 15.0),
                                ),
                              ],
                            )),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductPage(
                                        produto: snapshot.data[index],
                                      )));
                        },
                      ),
                    ],
                  );
                },
              ),
              onEndOfPage: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => Center(
                      child: AlertDialog(
                        title: const Text(
                          "Fim da página",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          "Você deseja carregar mais produtos ?",
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _pageController();
                            },
                            child: const Text(
                              "Sim",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Não",
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                        elevation: 24.0,
                        backgroundColor: color,
                      ),
                    ),
                  ));
        })
      ],
    );
  }
}
