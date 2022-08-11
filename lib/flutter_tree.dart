library packages;

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

  const Config(
      {this.dataType = DataType.DataList,
      this.parentId = 'parentId',
      this.label = 'name',
      this.id = 'id',
      this.children = 'children',
      this.allCheckedNodeName = '全部'});
}

/// @desc components
class FlutterTreePro extends StatefulWidget {
  /// source data type Map
  final Map<String, dynamic> treeData;

  /// source data type List
  final List<Map<String, dynamic>> listData;

  final Function(List<dynamic>) onChecked;

  /// Config
  final Config config;

  /// if expanded items
  final bool isExpanded;

  FlutterTreePro({
    Key? key,
    this.treeData = const <String, dynamic>{},
    this.config = const Config(),
    this.listData = const <Map<String, dynamic>>[],
    required this.onChecked,
    this.isExpanded = false,
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

  @override
  initState() {
    super.initState();
    // set default select
    if (widget.config.dataType == DataType.DataList) {
      var listToMap =
          DataUtil.transformListToMap(widget.listData, widget.config);
      sourceTreeMap = listToMap;
      factoryTreeData(sourceTreeMap);
    } else {
      sourceTreeMap = widget.treeData;
    }
    allCheckedNode['name'] = widget.config.allCheckedNodeName;
    allCheckedNode['checked'] = CheckStatus.checked;
  }

  /// @params
  /// @desc set current item checked
  setCheckStatus(item) {
    item['checked'] = CheckStatus.checked;
    if (item['children'] != null) {
      item['children'].forEach((element) {
        setCheckStatus(element);
      });
    }
  }

  /// @params
  /// @desc expand tree data to map
  factoryTreeData(treeModel) {
    treeModel['open'] = widget.isExpanded;
    treeModel['checked'] = CheckStatus.unChecked;
    treeMap.putIfAbsent(treeModel[widget.config.id], () => treeModel);
    (treeModel[widget.config.children] ?? []).forEach((element) {
      factoryTreeData(element);
    });
  }

  /// @params
  /// @desc render root
  buildTreeRootList() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onOpenNode(sourceTreeMap),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAllCheckedNode(),
                Column(children: _buildTreeNodeList(sourceTreeMap))
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildAllCheckedNode() {
    return _buildTreeNode(allCheckedNode, isAllNode: true);
  }

  _buildTreeNodeList(Map<String, dynamic> data) {
    return (data[widget.config.children] ?? [])
        .map<Widget>((treeNode) => _buildTreeNode(treeNode))
        .toList();
  }

  Widget _buildTreeNode(Map<String, dynamic> treeNode,
      {bool isAllNode = false}) {
    return GestureDetector(
      onTap: () => onOpenNode(treeNode),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => selectCheckedBox(treeNode, isAllNode: isAllNode),
                  child: _buildCheckBoxIcon(treeNode),
                ),
                SizedBox(width: 8),
                _buildCheckBoxLabel(treeNode),
                SizedBox(width: 8),
                (treeNode[widget.config.children] ?? []).isNotEmpty
                    ? Icon(
                        (treeNode['open'] ?? false)
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_right,
                        size: 24,
                        color: Color(0xFF767676),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            (treeNode['open'] ?? false)
                ? Column(
                    children: _buildTreeNodeList(treeNode),
                  )
                : SizedBox.shrink(),
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
  onOpenNode(Map<String, dynamic> treeNode) {
    if ((treeNode[widget.config.children] ?? []).isEmpty) return;
    treeNode['open'] = !treeNode['open'];
    setState(() {
      sourceTreeMap = sourceTreeMap;
    });
  }

  /// @params
  /// @desc 选中帅选框
  selectCheckedBox(Map<String, dynamic> treeNode, {bool isAllNode = false}) {
    CheckStatus checked = treeNode['checked'];
    if (isAllNode) {
      if (checked == CheckStatus.unChecked) {
        if ((sourceTreeMap[widget.config.children] ?? []).isNotEmpty) {
          _deepChangeCheckStatus(CheckStatus.checked, sourceTreeMap);
        }
      }
    } else {
      if ((treeNode[widget.config.children] ?? []).isNotEmpty) {
        _deepChangeCheckStatus(checked, treeNode);
      } else {
        if (checked == CheckStatus.checked) {
          treeNode['checked'] = CheckStatus.unChecked;
        } else {
          treeNode['checked'] = CheckStatus.checked;
        }
      }

      // 父节点
      var parentId = treeNode[widget.config.parentId];
      if (parentId != null && parentId != "0" && parentId != "") {
        updateParentNode(treeNode);
      }
    }

    setState(() {
      sourceTreeMap = sourceTreeMap;
    });

    getCheckedItems();
  }

  void _deepChangeCheckStatus(
      CheckStatus checked, Map<String, dynamic> treeNode) {
    var stack = MStack();
    stack.push(treeNode);
    while (stack.top > 0) {
      Map<String, dynamic> node = stack.pop();
      for (var item in node[widget.config.children] ?? []) {
        stack.push(item);
      }
      if (checked == CheckStatus.checked) {
        node['checked'] = CheckStatus.unChecked;
      } else {
        node['checked'] = CheckStatus.checked;
      }
    }
  }

  /// @params
  /// @desc 获取选中的条目
  getCheckedItems() {
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
    widget.onChecked(this.checkedList);
  }

  void _modifyAllCheckedNode(bool hasCheckedNode) {
    setState(() {
      allCheckedNode['checked'] =
          hasCheckedNode ? CheckStatus.unChecked : CheckStatus.checked;
    });
  }

  /// @params
  /// @desc
  updateParentNode(Map<String, dynamic> dataModel) {
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
      updateParentNode(par);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBreadcrumb(),
          SizedBox(
            height: 334,
            child: SingleChildScrollView(
              child: buildTreeRootList(),
            ),
          ),
          _buildToolBar()
        ],
      ),
    );
  }

  _buildBreadcrumb() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          const Text('服务集团',
              style: TextStyle(
                  color: Colors.black, //Color(0xFF434343),
                  fontSize: 14,
                  fontWeight: FontWeight.w500))
        ],
      ),
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
            onPressed: () {
              if (allCheckedNode['checked'] == CheckStatus.unChecked) {
                selectCheckedBox(allCheckedNode, isAllNode: true);
              }
            },
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
            onPressed: () => widget.onChecked(this.checkedList),
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
