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

  //默认数据
  List<Map<String, dynamic>> initialTreeData = [
    {"parent_id": 1063, "name": "牡丹江市", "id": 1314},
    {"parent_id": 1063, "name": "齐齐哈尔市", "id": 1318},
    {"parent_id": 1063, "name": "佳木斯市", "id": 1320},
    {"parent_id": 1066, "name": "长春市", "id": 1323},
    {"parent_id": 1066, "name": "通化市", "id": 1325},
    {"parent_id": 1066, "name": "白山市", "id": 1328},
    {"parent_id": 1066, "name": "辽源市", "id": 1330},
    {"parent_id": 1066, "name": "松原市", "id": 1332},
    {"parent_id": 1009, "name": "南京市", "id": 1130},
    {"parent_id": 1009, "name": "无锡市", "id": 1132},
    {"parent_id": 1009, "name": "常州市", "id": 1133},
    {"parent_id": 1009, "name": "镇江市", "id": 1134},
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await rootBundle.loadString('assets/data.json');
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
              initialListData: initialTreeData,
              config: Config(
                id: 'id',
                parentId: 'parent_id',
                dataType: DataType.DataList,
                label: 'name',
              ),
              onChecked: (List<Map<String, dynamic>> checkedList) {
                logger.v(checkedList);
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
