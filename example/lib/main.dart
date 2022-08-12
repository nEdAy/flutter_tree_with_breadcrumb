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
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tree & Breadcrumb'),
            bottom: const TabBar(
              tabs: [
                Tab(text: '项目'),
                Tab(text: '标签'),
                Tab(text: '空间'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
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
