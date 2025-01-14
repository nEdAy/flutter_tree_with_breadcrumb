import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_with_breadcrumb/flutter_tree_with_breadcrumb.dart';

class SpaceIFilter extends StatefulWidget {
  SpaceIFilter({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SpaceIFilterState createState() => _SpaceIFilterState();
}

class _SpaceIFilterState extends State<SpaceIFilter> {
  List<Map<String, dynamic>> treeListData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await rootBundle.loadString('assets/space.json');
    setState(() {
      json.decode(response)['data'].forEach((item) {
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
        key: const Key('space'),
        listData: treeListData,
        config: const Config(
          breadcrumbRootName: '空间',
        ),
        isNotRootNode:
            (Map<String, dynamic> treeNode, Config config) {
          final parentId = treeNode[config.parentId];
          final id = treeNode[config.id];
          return parentId != null &&
              id != null &&
              treeNode[config.parentId] != treeNode[config.id];
        },
        onChecked: (Map<String, dynamic> sourceTreeMap,
            List<Map<String, dynamic>> checkedList,
            bool isNullCheckedNodeChecked) =>
            toSpaceList(checkedList),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  List<String> toSpaceList(Iterable iterable) {
    return iterable.map((filteringElement) {
      return filteringElement['id'].toString();
    }).toList();
  }
}
