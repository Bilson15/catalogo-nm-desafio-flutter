import 'dart:convert';
//import 'dart:html';
import 'package:flutter/services.dart';
import 'package:desafio_flutter/api_login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:desafio_flutter/view/products_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.errorCode}) : super(key: key);

  final int? errorCode;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final color = const Color.fromRGBO(4, 4, 145, 1.0);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Widget currentWidget;

  bool _btnEnabled = false;
  bool _passwordVisibility = false;

  TextEditingController _re = TextEditingController();
  TextEditingController _senha = TextEditingController();

  CockpitApi _cockpitApi = CockpitApi();

  bool _processing = false;

  int? _errorCode;

  static const _messages = {
    0: 'Utilize seu Re e Senha do Vtrine para Entrar no aplicativo',
    1: 'Credenciais inválidas, tente novamente',
    2: 'Acesso negado neste momento',
    3: 'Credenciais inválidas, tente novamente',
    4: 'Sessão expirada, faça login novamente',
    5: 'Sessão expirada, faça login novamente',
    6: 'Ocorreu uma falha, tente novamente',
    999: 'Não foi possível conectar, tente novamente'
  };

  @override
  Widget build(BuildContext context) {
    currentWidget = (_processing == false) ? _login() : _loading();

    return Scaffold(
      body: currentWidget,
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
    _errorCode = widget.errorCode ?? 0;
    _clearOldCredentials();
    _re.addListener(_enableSubmit);
    _senha.addListener(_enableSubmit);
  }

  void _enableSubmit() {
    setState(() {
      if (_re.text.isEmpty || _senha.text.isEmpty) {
        _btnEnabled = false;
      } else {
        _btnEnabled = true;
      }
    });
  }

  @override
  void dispose() {
    _re.dispose();
    _senha.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _loading() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(backgroundColor: color),
        ),
      ),
    );
  }

  Widget _login() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width * 0.5,
              ),
              Container(
                  padding: (_messages[_errorCode]!.isEmpty)
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 5.0),
                  child: Text(_messages[_errorCode]!,
                      style: TextStyle(color: color),
                      textAlign: TextAlign.center)),
              Container(
                padding: const EdgeInsets.all(30.0),
                child: const Image(
                  image: AssetImage("assets/logo-azul.png"),
                  width: 150.0,
                  height: 150.0,
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _re,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: color),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: color),
                    ),
                    icon: Icon(
                      Icons.person,
                      color: color,
                    ),
                    labelText: "RE",
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    labelStyle: TextStyle(color: color, fontSize: 15.0),
                    border: const OutlineInputBorder()),
                style: TextStyle(color: color, fontSize: 15.0),
                cursorColor: color,
              ),
              const Padding(padding: EdgeInsets.all(10.0)),
              TextFormField(
                controller: _senha,
                obscureText: _passwordVisibility ? false : true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color),
                  ),
                  icon: Icon(
                    Icons.lock,
                    color: color,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_passwordVisibility == true) {
                          _passwordVisibility = false;
                        } else {
                          _passwordVisibility = true;
                        }
                      });
                    },
                    icon: _passwordVisibility
                        ? Icon(
                            Icons.visibility,
                            color: color,
                          )
                        : Icon(
                            Icons.visibility_off,
                            color: color,
                          ),
                  ),
                  labelText: "Senha",
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  labelStyle: TextStyle(color: color, fontSize: 15.0),
                ),
                style: TextStyle(color: color, fontSize: 15.0),
                cursorColor: color,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 50.0, 0, 0),
              ),
              SizedBox(
                height: 50.0,
                width: 150.0,
                child: ElevatedButton(
                  onPressed: (_btnEnabled == true) ? _submit : null,
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    setState(() {
      _processing = true;
      _errorCode = 0;
    });
    _proccessForm();
  }

  _proccessForm() async {
    if (!mounted) return;

    var credentials = {'uid': _re.text, 'password': _senha.text};

    var options = {};

    options['body'] = json.encode(credentials);

    await _cockpitApi
        .postRequest(
      urlSegment: '/auth/ldap/login',
      options: options,
      checkAuth: false,
    )
        .whenComplete(() {
      if (_cockpitApi.error == false && _cockpitApi.statusCode == 200) {
        try {
          var user = json.decode(_cockpitApi.body)['data'];

          _setLoggedUser(user).whenComplete(() {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (context) => ProductsPage()));
          });
        } catch (e) {
          _errorCode = 999;
        }
      } else if (_cockpitApi.statusCode == 401) {
        var data = json.decode(_cockpitApi.body);

        if (data.containsKey('code')) {
          _errorCode = data['code'];
        }
      } else {
        _errorCode = 999;
      }
    });
    setState(() {
      _processing = false;
    });
  }

  _clearOldCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('user.uid');
    prefs.remove('user.name');
    prefs.remove('user.email');
    prefs.remove('user.token');
    prefs.remove('user.menu');
    prefs.remove('apps');
  }

  Future _setLoggedUser(user) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('user.uid', user['uid']);
    prefs.setString('user.name', user['name']);
    prefs.setString('user.email', user['email']);
    prefs.setString('user.token', user['token']);
    prefs.setString('user.menu', json.encode(user['menu']));
    prefs.setString('apps', json.encode(user['apps']));
  }
}
