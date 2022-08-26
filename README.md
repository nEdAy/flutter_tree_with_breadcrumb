# packages

Flutter tree select with breadcrumb widget.

# Screenshot

![flutter_tree_with_breadcrumb](screenshot/1661495160371.jpg)

## Usage
To use this plugin, add flutter_tree_with_breadcrumb as a dependency in your pubspec.yaml file.
```
dependencies:
  flutter_tree_with_breadcrumb: ^0.1.1
```
Use as a widget
```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter tree with breadcrumb')),
      body: Container(
        child: FlutterTree(
          listData: treeListData,
          initialListData: initialTreeData,
          config: Config(
            parentId: 'parentId',
            dataType: DataType.DataList,
            label: 'value',
          ),
          onChecked: (List<Map<String, dynamic>> checkedList) {},
        ),
      ),
    );
  }
```

## Property
| property | description |
| --- | --- |
| listData | The data source |
| initialListData | The initial data source |
| parentId | The key name of parent id |
| dataType | The type of data source |
| label | The key name of the value |
| onChecked | The item checked callback function |
