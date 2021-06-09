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
  late TextEditingController _editingController;
  late ScrollController _scrollController;
  int _page = 1;

  Future<String> getJsonData() async {
    String kakaoRestApiKey = '';
    String query = _editingController.value.text;
    var uri = Uri.parse(
        'https://dapi.kakao.com/v3/search/book?target=title&query=$query&page=$_page');
    var response = await http
        .get(uri, headers: {"Authorization": "KakaoAK $kakaoRestApiKey"});
    setState(() {
      var jsonData = json.decode(response.body);
      List results = jsonData['documents'];
      data.addAll(results);
    });
    return response.body;
  }

  @override
  void initState() {
    super.initState();
    data = [];
    _editingController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      var offset = _scrollController.offset;
      var position = _scrollController.position;
      if (offset >= position.maxScrollExtent && !position.outOfRange) {
        print("bottom");
        _page++;
        getJsonData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
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
                              Text(
                                  '가격 : ${data[index]['sale_price'].toString()}'),
                              Text('판매중 : ${data[index]['status'].toString()}'),
                            ],
                          ),
                        ],
                      ),
                    ));
                  },
                  itemCount: data.length,
                  controller: _scrollController,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _page = 1;
          data.clear();
          getJsonData();
        },
        child: Icon(Icons.file_download),
      ),
    );
  }
}
