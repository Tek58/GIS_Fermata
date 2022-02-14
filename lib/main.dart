import 'package:flutter/material.dart';
//import 'package:flutter_map_example/pages/map_inside_listview.dart';
//import 'package:flutter_map_example/pages/network_tile_provider.dart';
import './pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ProjecX",

    home: Home(),
    );
  }
}
