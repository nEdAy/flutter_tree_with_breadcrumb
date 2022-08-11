import '../flutter_tree.dart';

/// @create at 2021/7/15 15:01
/// @create by kevin
/// @desc

class DataUtil {
  /// @params
  /// @desc  List to map
  static Map<String, dynamic> transformListToMap(
      List<Map<String, dynamic>> dataList, Config config) {
    Map obj = {};
    String? rootId;
    dataList.forEach((v) {
      if (v.containsKey([config.id])) {
        v[config.id] = v[config.id].toString();
      }
      // 根节点
      if (v.containsKey(config.parentId)) {
        v[config.parentId] = v[config.parentId].toString();
        final parentId = v[config.parentId];
        if (parentId != null && parentId != "0" && parentId != "") {
          if (obj[parentId] != null) {
            if (obj[parentId][config.children] != null) {
              obj[parentId][config.children].add(v);
            } else {
              obj[parentId][config.children] = [v];
            }
          } else {
            obj[parentId] = {
              config.children: [v],
            };
          }
        } else if (rootId == null) {
          rootId = v[config.id];
        }
      } else if (rootId == null) {
        rootId = v[config.id];
      }
      if (v.containsKey(config.id) && obj[v[config.id]] != null) {
        v[config.children] = obj[v[config.id]][config.children];
      }
      obj[v[config.id]] = v;
    });
    return obj[rootId] ?? {};
  }
}
