import 'package:example/filter/space.dart';
import 'package:example/filter/tag.dart';
import 'package:flutter/material.dart';

import 'filter/data.dart';
import 'filter/project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tree & Breadcrumb'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Data'),
                Tab(text: '项目'),
                Tab(text: '标签'),
                Tab(text: '空间'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DataIFilter(title: 'Data'),
              ProjectIFilter(title: '项目'),
              TagIFilter(title: '标签'),
              SpaceIFilter(title: '空间'),
            ],
          ),
        ),
      ),
    );
  }
}
