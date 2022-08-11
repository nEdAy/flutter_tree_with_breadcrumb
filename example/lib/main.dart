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
    var response = await rootBundle.loadString('assets/project.json');
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
                parentId: 'parent_id',
                allCheckedNodeName: '全部项目',
              ),
              onChecked: (List<dynamic> checkedList) {
                // for 空间 (checked 父节点、叶子节点)
                final checkedProjectList = toProjectList(checkedList);
                print('父节点、叶子节点：${checkedProjectList.length}');

                // for 项目、标签 (checked 叶子节点)
                final leafNodeList = filteringLeafNode(checkedList);
                final leafProjectList = toProjectList(leafNodeList);
                print('叶子节点：${leafProjectList.length}');

                // for 项目、标签、空间
                final checkedNodeCount = checkedProjectList.length;
                if (checkedNodeCount == 0) {
                  print('输出：${null}');
                } else {
                  // print('输出：$checkedProjectList');
                  print('输出：$leafProjectList');
                }
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Iterable filteringLeafNode(List<dynamic> checkedList) {
    return checkedList.where((element) =>
        element.containsKey('project_id') &&
        element.containsKey('type') &&
        element['type'] == 2 &&
        element['project_id'] != null);
  }

  List<String> toProjectList(Iterable iterable) {
    return iterable.map((filteringElement) {
      return filteringElement['project_id'].toString();
    }).toList();
  }
}
