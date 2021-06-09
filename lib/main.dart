import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HttpApp(),
    );
  }
}

class HttpApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HttpAppState();
}

class _HttpAppState extends State<HttpApp> {
  String result = '';
  late List data;

  @override
  void initState() {
    super.initState();
    data = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Http Example'),
      ),
      body: Container(
        child: Center(
          child: data.isEmpty
              ? Text(
                  '데이터가 없습니다.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                        child: Container(
                      child: Row(
                        children: [
                          Image.network(
                            data[index]['thumbnail'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 150,
                                child: Text(
                                  data[index]['title'].toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text('저자 : ${data[index]['authors'].toString()}'),
                              Text('가격 : ${data[index]['sale_price'].toString()}'),
                              Text('판매중 : ${data[index]['status'].toString()}'),
                            ],
                          ),
                        ],
                      ),
                    ));
                  },
                  itemCount: data.length,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getJsonData();
        },
        child: Icon(Icons.file_download),
      ),
    );
  }

  Future<String> getJsonData() async {
    String kakaoRestApiKey = '';
    var uri = Uri.parse(
        'https://dapi.kakao.com/v3/search/book?target=title&query=doit');
    var response = await http
        .get(uri, headers: {"Authorization": "KakaoAK $kakaoRestApiKey"});
    setState(() {
      var jsonData = json.decode(response.body);
      List results = jsonData['documents'];
      data.addAll(results);
    });
    return response.body;
  }
}
