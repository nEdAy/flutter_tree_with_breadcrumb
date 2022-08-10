import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_with_breadcrumb/flutter_tree_with_breadcrumb.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Flutter Tree Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> treeListData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await rootBundle.loadString('assets/response.json');
    setState(() {
      json.decode(response)['list'].forEach((item) {
        treeListData.add(item);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: treeListData.isNotEmpty
          ? FlutterTreePro(
              // isExpanded: true,
              listData: treeListData,
              config: Config(
                id: 'id',
                parentId: 'parent_id',
                dataType: DataType.DataList,
                label: 'name',
              ),
              onChecked: (List<dynamic> checkedList) {
                final leafNodeCheckedList = filteringLeafNode(checkedList);
                print(leafNodeCheckedList);
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  List<String> filteringLeafNode(List<dynamic> checkedList) {
    return checkedList
        .where((element) =>
            element.containsKey('project_id') &&
            element.containsKey('type') &&
            element['type'] == 2 &&
            element['project_id'] != null)
        .map((filteringElement) {
      return filteringElement['project_id'].toString();
    }).toList();
  }
}
