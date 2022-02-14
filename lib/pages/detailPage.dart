// ignore: file_names
import 'package:flutter/material.dart';

import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';


// ignore: camel_case_types
class detailPage extends StatelessWidget {
  final List itemHolder;

  detailPage({Key? key, required this.itemHolder}) : super(key: key);

  goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var lat = double.parse(itemHolder[1][0]);
    var longt = double.parse(itemHolder[2][0]);
  //  print("1st" + itemHolder[1]);
    //print(itemHolder[1]);
    return Scaffold(
     appBar: AppBar(title: Text(itemHolder[0])),
      // drawer: buildDrawer(context, MapInsideListViewPage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(
              height: 700,
            
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(lat, longt),
                  zoom: 17.0,
                  // plugins: [
                  //   ZoomButtonsPlugin(),
                  // ],
                ),
                layers: [
                  // ZoomButtonsPluginOption(
                  //   minZoom: 4,
                  //   maxZoom: 19,
                  //   mini: true,
                  //   padding: 10,
                  //   alignment: Alignment.bottomLeft,
                  // )
                ],

                children: <Widget>[
                  TileLayerWidget(
                    options: TileLayerOptions(
                        urlTemplate: 'https://api.mapbox.com/styles/v1/gedlekiristos/ckye626kj5l9v14s8axk9hj9g/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2VkbGVraXJpc3RvcyIsImEiOiJja3hyZ3M5cGEwMmlwMm9vNWJmNG02MDFoIn0.PBHcecjt5JQaOUmsqdgU1g',
                        additionalOptions: {
                          'accessToken': 'pk.eyJ1IjoiZ2VkbGVraXJpc3RvcyIsImEiOiJja3hyZ3M5cGEwMmlwMm9vNWJmNG02MDFoIn0.PBHcecjt5JQaOUmsqdgU1g',
                          'id' : 'mapbox.mapbox-streets-v8'
                        }
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                  title: Text(
                      'Scrolling inside the map does not scroll the ListView')),
            ),
            SizedBox(height: 500),
            Card(child: ListTile(title: Text('look at that scrolling')))
          ],
        ),
      ),
    );
  }
}
