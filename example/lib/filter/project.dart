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
              listData: treeListData,
              config: Config(
                parentId: 'parent_id',
                allCheckedNodeName: '全部项目',
                breadcrumbRootName: '服务集团',
              ),
              onFilteringLeafNode: (Iterable iterable) {
                return filteringProjectLeafNode(iterable);
              },
              onCropStringList: (Iterable iterable) {
                return toProjectList(iterable);
              },
              isNotRootNode: (Map<String, dynamic> treeNode, Config config) {
                final parentId = treeNode[config.parentId];
                return parentId != null;
              },
              onChecked: (Iterable checkedList, bool isNullCheckedNodeChecked) {
                final checkedNodeCount = checkedList.length;
                if (checkedNodeCount == 0) {
                  print('输出：${null}');
                } else {
                  print('输出：$checkedList');
                }
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Iterable filteringProjectLeafNode(Iterable checkedList) {
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
