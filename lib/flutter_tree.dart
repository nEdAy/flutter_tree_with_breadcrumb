library packages;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_tree_with_breadcrumb.dart';

enum DataType {
  DataList,
  DataMap,
}

/// @desc  参数类型配置
class Config {
  ///数据类型
  final DataType dataType;

  ///父级id key
  final String parentId;

  final String label;

  final String id;

  final String children;

  final String allCheckedNodeName;

  final String breadcrumbRootName;

  const Config(
      {this.dataType = DataType.DataList,
      this.parentId = 'parentId',
      this.label = 'name',
      this.id = 'id',
      this.children = 'children',
      this.allCheckedNodeName = '全部',
      this.breadcrumbRootName = '根'});
}

/// @desc components
class FlutterTreePro extends StatefulWidget {
  /// source data type Map
  final Map<String, dynamic> treeData;

  /// source data type List
  final List<Map<String, dynamic>> listData;

  final Function(Iterable) onChecked;

  final Iterable Function(Iterable)? onFilteringLeafNode;

  final List<String> Function(Iterable)? onCropStringList;

  final bool Function(Map<String, dynamic>, Config) isNotRootNode;

  /// Config
  final Config config;

  FlutterTreePro({
    Key? key,
    this.treeData = const <String, dynamic>{},
    this.config = const Config(),
    this.listData = const <Map<String, dynamic>>[],
    this.onFilteringLeafNode,
    this.onCropStringList,
    required this.isNotRootNode,
    required this.onChecked,
  }) : super(key: key);

  @override
  _FlutterTreeProState createState() => _FlutterTreeProState();
}

enum CheckStatus {
  unChecked,
  partChecked,
  checked,
}

class _FlutterTreeProState extends State<FlutterTreePro> {
  Map<String, dynamic> sourceTreeMap = {};

  bool checkedBox = false;

  /// @desc expand map tree to map
  Map treeMap = {};

  List<dynamic> checkedList = [];

  Map<String, dynamic> allCheckedNode = {};

  List<Map<String, dynamic>> _breadcrumbList = [];

  @override
  initState() {
    super.initState();
    // set default select
    if (widget.config.dataType == DataType.DataList) {
      var listToMap = DataUtil.transformListToMap(
          widget.listData, widget.config, widget.isNotRootNode);
      sourceTreeMap = listToMap;
      _factoryTreeData(sourceTreeMap);
    } else {
      sourceTreeMap = widget.treeData;
    }
    _breadcrumbList.add(sourceTreeMap);
    allCheckedNode['name'] = widget.config.allCheckedNodeName;
    allCheckedNode['checked'] = CheckStatus.checked;
  }

  /// @params
  /// @desc expand tree data to map
  _factoryTreeData(treeModel) {
    treeModel['checked'] = CheckStatus.unChecked;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      _factoryTreeData(element);
    });
  }

  ScrollController _treeNodeController = ScrollController();

  _treeNodeListToTop() {
    Timer(Duration(milliseconds: 0), () {
      if (_treeNodeController.hasClients) {
        _treeNodeController
            .jumpTo(_treeNodeController.position.minScrollExtent);
      }
    });
  }

  _buildTreeRootList() {
    final children = _breadcrumbList.last[widget.config.children];
    if (children == null || children.length == 0) {
      return Expanded(child: SizedBox.shrink());
    }
    return Expanded(
      child: ListView.separated(
        controller: _treeNodeController,
        itemBuilder: (context, index) {
          final treeNode = children[index];
          if (treeNode != null) {
            if (_breadcrumbList.length == 1 && index == 0) {
              return Column(
                children: [
                  _buildTreeNode(allCheckedNode, isAllNode: true),
                  _buildTreeNode(treeNode)
                ],
              );
            }
            return _buildTreeNode(treeNode);
          } else {
            return SizedBox.shrink();
          }
        },
        separatorBuilder: (context, index) {
          return Container(
            color: Colors.white,
            child: const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F0F0),
              indent: 20,
              endIndent: 20,
            ),
          );
        },
        itemCount: children.length,
      ),
    );
  }

  Widget _buildTreeNode(Map<String, dynamic> treeNode,
      {bool isAllNode = false}) {
    return GestureDetector(
      onTap: () => _onOpenNode(treeNode),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      _selectCheckedBox(treeNode, isAllNode: isAllNode),
                  child: _buildCheckBoxIcon(treeNode),
                ),
                SizedBox(width: 8),
                _buildCheckBoxLabel(treeNode),
                SizedBox(width: 8),
                (treeNode[widget.config.children] ?? []).isNotEmpty
                    ? Icon(
                        Icons.keyboard_arrow_right,
                        size: 24,
                        color: Color(0xFF767676),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// @params
  /// @desc render icon by checked type
  Icon _buildCheckBoxIcon(Map<String, dynamic> treeNode) {
    switch (treeNode['checked'] as CheckStatus) {
      case CheckStatus.unChecked:
        return Icon(
          Icons.check_box_outline_blank,
          color: Color(0XFF737373),
          size: 24,
        );
      case CheckStatus.partChecked:
        return Icon(
          Icons.indeterminate_check_box,
          color: Color(0XFFDE7F02),
          size: 24,
        );
      case CheckStatus.checked:
        return Icon(
          Icons.check_box,
          color: Color(0XFFDE7F02),
          size: 24,
        );
    }
  }

  _buildCheckBoxLabel(Map<String, dynamic> treeNode) {
    final isChecked = treeNode['checked'] != CheckStatus.unChecked;
    return Expanded(
      child: Text(
        '${treeNode[widget.config.label]}',
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 16,
            color: isChecked ? Color(0xFFD97F00) : Color(0xFF434343),
            fontWeight: isChecked ? FontWeight.w500 : FontWeight.w400),
      ),
    );
  }

  /// @params
  /// @desc expand item if has item has children
  _onOpenNode(Map<String, dynamic> treeNode) {
    if ((treeNode[widget.config.children] ?? []).isEmpty) return;
    setState(() {
      _breadcrumbList.add(treeNode);
    });
    _treeNodeListToTop();
  }

  /// @desc set current treeNode checked/unChecked
  _deepChangeCheckStatus(Map<String, dynamic> treeNode, bool checked) {
    var stack = MStack();
    stack.push(treeNode);
    while (stack.top > 0) {
      Map<String, dynamic> node = stack.pop();
      for (var item in node[widget.config.children] ?? []) {
        stack.push(item);
      }
      node['checked'] = checked ? CheckStatus.checked : CheckStatus.unChecked;
    }
  }

  /// @desc 选中选框
  _selectCheckedBox(Map<String, dynamic> treeNode, {bool isAllNode = false}) {
    CheckStatus checked = treeNode['checked'];
    if (isAllNode) {
      if (checked == CheckStatus.unChecked) {
        if ((sourceTreeMap[widget.config.children] ?? []).isNotEmpty) {
          _deepChangeCheckStatus(sourceTreeMap, false);
        }
      }
    } else {
      _deepChangeCheckStatus(
          treeNode, treeNode['checked'] != CheckStatus.checked);

      // 有父节点
      if (widget.isNotRootNode(treeNode, widget.config)) {
        _updateParentNode(treeNode);
      }
    }

    setState(() {
      sourceTreeMap = sourceTreeMap;
    });

    _getCheckedItems();
  }

  /// @desc 获取选中的条目
  _getCheckedItems() {
    var stack = MStack();
    var checkedList = [];
    stack.push(sourceTreeMap);
    while (stack.top > 0) {
      var node = stack.pop();
      for (var item in (node[widget.config.children] ?? [])) {
        stack.push(item);
      }
      if (node['checked'] == CheckStatus.checked) {
        checkedList.add(node);
      }
    }

    final hasCheckedNode = checkedList.length > 0;
    _modifyAllCheckedNode(hasCheckedNode);

    this.checkedList = checkedList;
  }

  _modifyAllCheckedNode(bool hasCheckedNode) {
    setState(() {
      allCheckedNode['checked'] =
          hasCheckedNode ? CheckStatus.unChecked : CheckStatus.checked;
    });
  }

  _updateParentNode(Map<String, dynamic> dataModel) {
    var par = treeMap[dataModel[widget.config.parentId]];
    if (par == null) return;
    int checkLen = 0;
    bool partChecked = false;
    for (var item in (par[widget.config.children] ?? [])) {
      if (item['checked'] == CheckStatus.checked) {
        checkLen++;
      } else if (item['checked'] == CheckStatus.partChecked) {
        partChecked = true;
        break;
      }
    }

    // 如果子孩子全都是选择的，父节点就全选
    if (checkLen == (par[widget.config.children] ?? []).length) {
      par['checked'] = CheckStatus.checked;
    } else if (partChecked ||
        (checkLen < (par[widget.config.children] ?? []).length &&
            checkLen > 0)) {
      par['checked'] = CheckStatus.partChecked;
    } else {
      par['checked'] = CheckStatus.unChecked;
    }

    // 如果还有父节点 解析往上更新
    if (treeMap[par[widget.config.parentId]] != null ||
        treeMap[par[widget.config.parentId]] == "0" ||
        treeMap[par[widget.config.parentId]] == "") {
      _updateParentNode(par);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 468,
      color: Colors.white,
      child: Column(
        children: [
          _buildBreadcrumb(),
          _buildTreeRootList(),
          _buildToolBar(),
        ],
      ),
    );
  }

  ScrollController _breadcrumbController = ScrollController();

  _buildBreadcrumb() {
    if (_breadcrumbList.length > 0) {
      Timer(Duration(milliseconds: 0), () {
        if (_treeNodeController.hasClients) {
          _breadcrumbController
              .jumpTo(_breadcrumbController.position.maxScrollExtent);
        }
      });
    } else {
      return SizedBox.shrink();
    }
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _breadcrumbController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return _buildBreadcrumbNode(index);
              },
              separatorBuilder: (context, index) {
                return SizedBox(width: 4);
              },
              itemCount: _breadcrumbList.length,
            ),
          ),
        ],
      ),
    );
  }

  _buildBreadcrumbNode(int index) {
    final treeNode = _breadcrumbList[index];
    if (index == 0) {
      return _buildBreadcrumbNodeText(widget.config.breadcrumbRootName, index);
    }
    return Row(
      children: [
        Icon(
          Icons.keyboard_arrow_right,
          size: 16,
          color: Color(0xFFABABAB),
        ),
        SizedBox(width: 4),
        _buildBreadcrumbNodeText(treeNode[widget.config.label], index),
      ],
    );
  }

  _buildBreadcrumbNodeText(String label, int index) {
    return GestureDetector(
      child: Text(label,
          style: TextStyle(
              color: Colors.black, //Color(0xFF434343),
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      onTap: () {
        setState(() {
          _breadcrumbList = _breadcrumbList.take(index + 1).toList();
        });
        _treeNodeListToTop();
      },
    );
  }

  _buildToolBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Color(0xFFF0F0F0),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(10, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: allCheckedNode['checked'] == CheckStatus.unChecked
                ? () {
                    _selectCheckedBox(allCheckedNode, isAllNode: true);
                    setState(() {
                      _breadcrumbList = _breadcrumbList.take(1).toList();
                    });
                  }
                : null,
            style: TextButton.styleFrom(padding: EdgeInsets.all(10)),
            child: Text(
              '重置',
              style: TextStyle(
                  color: allCheckedNode['checked'] == CheckStatus.unChecked
                      ? Color(0xFF767676)
                      : Color(0xFFAAAAAA),
                  fontWeight: allCheckedNode['checked'] == CheckStatus.unChecked
                      ? FontWeight.w500
                      : FontWeight.w400,
                  fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Iterable outputList = this.checkedList;
              if (widget.onFilteringLeafNode != null) {
                outputList = widget.onFilteringLeafNode!(outputList);
              }
              if (widget.onCropStringList != null) {
                outputList = widget.onCropStringList!(outputList);
              }
              widget.onChecked(outputList);
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 63),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                backgroundColor: const Color(0xFFFF9F08)),
            child: const Text(
              '确定',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
