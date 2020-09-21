import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=b34d8053";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber[600],
      primaryColor: Colors.white,
      /* inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber[600])),
          hintStyle: TextStyle(color: Colors.amber[600]),
        )*/
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dolar;
  double euro;
  double bitcoin;

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
    bitcoinController.clear();
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    euroController.text = (real / euro).toStringAsFixed(3);
    dolarController.text = (real / dolar).toStringAsFixed(3);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(6);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(3);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(3);
    bitcoinController.text = (dolar * this.dolar / bitcoin).toStringAsFixed(6);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(3);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(3);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(6);
  }

  void _bitcoinChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(3);
    dolarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(3);
    euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de Câmbio"),
        backgroundColor: Colors.amber[600],
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _clearAll)
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados",
                  style: TextStyle(color: Colors.amber[600], fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(color: Colors.amber[600], fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150, color: Colors.amber[600]),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChanged),
                      Divider(),
                      buildTextField(
                          "Bitcoin", "₿ ", bitcoinController, _bitcoinChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController control, Function func) {
  return TextField(
    controller: control,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber[600]),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(15)),
        prefixText: prefix),
    style: TextStyle(
      color: Colors.amber[600],
      fontSize: 25,
    ),
    onChanged: func,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
