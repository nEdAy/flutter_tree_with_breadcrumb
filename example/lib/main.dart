import 'package:example/filter/space.dart';
import 'package:example/filter/tag.dart';
import 'package:flutter/material.dart';

import 'filter/project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      // home: ProjectIFilter(title: '项目'),
      home: TagIFilter(title: '标签'),
      // home: SpaceIFilter(title: '空间'),
    );
  }
}