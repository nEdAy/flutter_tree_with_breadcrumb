import '../flutter_tree.dart';

/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc

class DataUtil {
  /// @params
  /// @desc  List to map
  static Map<String, dynamic> transformListToMap(List dataList, Config config) {
    Map obj = {};
    String? rootId;
    dataList.forEach((v) {
      if (v[config.id] != null) {
        v[config.id] = v[config.id].toString();
      }
      // 根节点
      if (v[config.parentId] != null) {
        v[config.parentId] = v[config.parentId].toString();
        if (v[config.parentId] != "0") {
          if (obj[v[config.parentId]] != null) {
            if (obj[v[config.parentId]][config.children] != null) {
              obj[v[config.parentId]][config.children].add(v);
            } else {
              obj[v[config.parentId]][config.children] = [v];
            }
          } else {
            obj[v[config.parentId]] = {
              config.children: [v],
            };
          }
        } else {
          rootId = v[config.id];
        }
      } else {
        rootId = v[config.id];
      }
      if (obj[v[config.id]] != null) {
        v[config.children] = obj[v[config.id]][config.children];
      }
      obj[v[config.id]] = v;
    });
    return obj[rootId] ?? {};
  }
}
