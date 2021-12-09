import 'package:desafio_flutter/produto.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductPage extends StatefulWidget {
  ProductPage({Key? key, this.produto}) : super(key: key);

  Produto? produto;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Produto? _prodData = widget.produto;
  final color = const Color.fromRGBO(4, 4, 145, 1.0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_prodData!.nome!),
          backgroundColor: color,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
            ),
            Text(
              _prodData!.nome.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                  height: 400.0, enlargeCenterPage: true, autoPlay: true),
              items: _prodData!.url!
                  .map<Widget>((e) => Column(
                        children: <Widget>[
                          FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: e,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ))
                  .toList(),
            ),
            Text(
              _prodData!.descricao.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
            ),
            Text(
              "R\$ " + _prodData!.preco!.toStringAsFixed(2),
              style:
                  const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }
}
