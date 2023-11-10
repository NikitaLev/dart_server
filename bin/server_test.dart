import 'dart:convert';
import 'dart:io' as io;

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:json_response/json_response.dart';

Future<bool> google_req(String mail, String id_token) async {
  final queryParameters = {
    'id_token': id_token,
  };
  final uri =
      Uri.https('www.googleapis.com', '/oauth2/v1/tokeninfo', queryParameters);
  final response = await http.get(uri);

  Map<String, dynamic> json = jsonDecode(response.body);
  String email = json['email'];
  if (email == mail)
    return true;
  else
    return false;
}

void main(List<String> arguments) async {
  try {
    onRequest(io.HttpRequest request) async {
      try {
        print("receive requested ${request.uri}");
        String? mail = request.uri.queryParameters['mail'];
        String? id_token = request.uri.queryParameters['id_token'];
        var res = await google_req(mail!, id_token!);
        request.response.write(res);
        request.response.close();
      } catch (e, s) {
        print("${e}");
        print("${s}");
      }
    }

    String address = '127.0.0.1';
    int port = 443;
    String key = io.Platform.script.resolve('cert/loc1t.key').toFilePath();
    String crt = io.Platform.script.resolve('cert/loc1.crt').toFilePath();

    io.SecurityContext context = io.SecurityContext();
    context.useCertificateChain(crt);
    context.usePrivateKey(key, password: "test");
    var httpsServer = await io.HttpServer.bindSecure(address, port, context);
    print("listening on $address:$port");
    httpsServer.listen((request) {
      onRequest(request);
    });
  } catch (e, s) {
    print("${e}");
    print("${s}");
  }
}
