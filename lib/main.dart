import 'dart:convert' as convert;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Null Safety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter API'),
    );
  }
}

class GetData {
  String _url = "reqres.in";

  Future getApiData() async {
    var url = Uri.https(_url, '/api/user', {'page': '2'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['data'];
    } else {
      return [];
    }
  }

  //post data to api
  Future postApiData() async {
    var _data = {"name": "Michael", "job": "Web Dev"};
    var url = Uri.https(_url, '/api/users');
    var response = await http.post(url, body: _data);
    if (response.statusCode == 201) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } else {
      return null;
    }
  }

  //put data to api
  Future putApiData(String id) async {
    var _data = {"name": "Michael", "job": "Web Dev"};
    var url = Uri.https(_url, '/api/users/$id');
    var response = await http.put(url, body: _data);
    inspect(response);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } else {
      return null;
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, this.data = ""});

  final String title;
  final String data;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _data = [];
  bool _isLoading = false;
  var _putData;

  GetDataLocal() {
    GetData().getApiData().then((value) {
      setState(() {
        _data = value;
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetDataLocal();
    _isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _data.isEmpty ? 1 : _data.length,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  if (_data.isEmpty) {
                    return Center(
                        child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey[300]),
                          child: const Icon(
                            Icons.clear_rounded,
                            size: 100,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "No Data",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ));
                  }
                  return Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 20),
                    color: Colors.white,
                    child: Text(_data[index]['name']),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await GetData().putApiData('2').then((value) {
            setState(() {
              _putData = value;
            });
            if (_putData != null) {
              final snackBar = SnackBar(
                content: Text(
                    '${_putData["name"]} | ${_putData["job"]} update success'),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                    // Some code to undo the change.
                  },
                ),
              );

              // Find the ScaffoldMessenger in the widget tree
              // and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.upload_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
