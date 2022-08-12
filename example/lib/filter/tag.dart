import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tree_with_breadcrumb/flutter_tree_with_breadcrumb.dart';

class TagIFilter extends StatefulWidget {
  TagIFilter({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TagIFilterState createState() => _TagIFilterState();
}

class _TagIFilterState extends State<TagIFilter> {
  List<Map<String, dynamic>> treeListData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var response = await rootBundle.loadString('assets/tag.json');
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
              listData: treeListData,
              config: Config(
                breadcrumbRootName: '标签',
                nullCheckedNodeName: '无标签',
              ),
              onCropStringList: (Iterable iterable) {
                return toTagList(iterable);
              },
              isNotRootNode: (Map<String, dynamic> treeNode, Config config) {
                final parentId = treeNode[config.parentId];
                final type = treeNode['type'];
                return parentId != null &&
                    parentId != "" &&
                    type != null &&
                    type != 'ALL';
              },
              onChecked: (Iterable checkedList, bool isNullCheckedNodeChecked) {
                final checkedNodeCount = checkedList.length;
                if (checkedNodeCount == 0) {
                  if (isNullCheckedNodeChecked) {
                    print('输出：${[]}');
                  } else {
                    print('输出：${null}');
                  }
                } else {
                  print('输出：$checkedList');
                }
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  List<String> toTagList(Iterable iterable) {
    return iterable.map((filteringElement) {
      return filteringElement['id'].toString();
    }).toList();
  }
}
