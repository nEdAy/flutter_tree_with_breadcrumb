import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_with_breadcrumb/flutter_tree_with_breadcrumb.dart';

class ProjectIFilter extends StatefulWidget {
  ProjectIFilter({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ProjectIFilterState createState() => _ProjectIFilterState();
}

class _ProjectIFilterState extends State<ProjectIFilter> {
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
              key: const Key('project'),
              listData: treeListData,
              config: const Config(
                allCheckedNodeName: '全部项目',
                breadcrumbRootName: '服务集团',
              ),
              isNotRootNode: (Map<String, dynamic> treeNode, Config config) {
                final parentId = treeNode[config.parentId];
                return parentId != null && parentId != '' && parentId != 'null';
              },
              onChecked: (Map<String, dynamic> sourceTreeMap,
                      List<Map<String, dynamic>> checkedList,
                      bool isNullCheckedNodeChecked) =>
                  toProjectList(filteringProjectLeafNode(checkedList)))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  List<Map<String, dynamic>> filteringProjectLeafNode(
      List<Map<String, dynamic>> checkedList) {
    checkedList.retainWhere((element) =>
    element.containsKey('projectId') &&
        element.containsKey('type') &&
        element['type'] == 2 &&
        element['projectId'] != "null");
    return checkedList;
  }

  List<String> toProjectList(List<Map<String, dynamic>> iterable) {
    return iterable.map((filteringElement) {
      return filteringElement['project_id'].toString();
    }).toList();
  }
}
