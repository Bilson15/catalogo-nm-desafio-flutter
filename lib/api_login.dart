import 'dart:async';
import 'dart:io';
import 'package:desafio_flutter/util.dart';
import 'package:desafio_flutter/view/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:desafio_flutter/view/products_page.dart';

class CockpitApi {
  String body;
  int statusCode;
  bool error;

  CockpitApi({this.body = '', this.statusCode = 0, this.error = false});

  final String _baseUrl = 'https://cockpit.novomundo.com.br/api';

  String _token = '';

  Future postRequest({
    @required String? urlSegment,
    var options,
    bool checkAuth = true,
  }) async {
    var url = Uri.parse(_baseUrl + urlSegment!);

    error = false;

    try {
      _token = await getStringFromSP('user.token');
      await http
          .post(url,
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader: "Basic $_token",
              },
              body: options['body'])
          .timeout(const Duration(seconds: 60))
          .then((response) {
        statusCode = response.statusCode;
        body = response.body;
      });
    } catch (e) {
      error = true;
    }
  }
}
