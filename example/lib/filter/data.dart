import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_with_breadcrumb/flutter_tree_with_breadcrumb.dart';

class DataIFilter extends StatefulWidget {
  DataIFilter({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _DataIFilterState createState() => _DataIFilterState();
}

class _DataIFilterState extends State<DataIFilter> {
  List<Map<String, dynamic>> treeListData = [];

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
              key: const Key('tag'),
              listData: treeListData,
              config: const Config(
                breadcrumbRootName: '根节点',
                parentId: 'parent_id'
              ),
              isNotRootNode: (Map<String, dynamic> treeNode, Config config) {
                final parentId = treeNode[config.parentId];
                return parentId != null &&
                    parentId != "0";
              },
              onChecked: (Map<String, dynamic> sourceTreeMap,
                      List<Map<String, dynamic>> checkedList,
                      bool isNullCheckedNodeChecked) =>
                  toDataList(checkedList),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  List<String> toDataList(Iterable iterable) {
    return iterable.map((filteringElement) {
      return filteringElement['id'].toString();
    }).toList();
  }
}
