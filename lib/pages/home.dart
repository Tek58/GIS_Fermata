import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geolocator/geolocator.dart';
// import 'package:latlng/latlng.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as geo;
import './detailPage.dart';
import 'package:map_launcher/map_launcher.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Stop',
      debugShowCheckedModeBanner: false,

      // theme: ThemeData(
      //   primarySwatch: Colors.white10,
      // ),

      home: const MyHomePage(title: 'ProjectX'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}
enum LaunchMode { marker , directions}
class _MyHomePageState extends State<MyHomePage> {
  MapController controller = new MapController();
  var points = <LatLng>[
    new LatLng(9.055598 , 38.7739939),
    new LatLng(8.996607374412472 , 38.80892243952237),
    new LatLng(9.042270362431195 , 38.74999015396373),
    new LatLng( 9.011926934609333 , 38.74761685554566),
    new LatLng( 8.95990064866166 , 38.7115287780762 ),
  ];


  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _centerCurrentLocationStreamController;
  String location = 'Null , Press Button';
  bool _searchBoolean = false;
  List<int> _searchIndexList = [];

  geo.LocationData? _currentLocation;
  late final MapController _mapController;

  bool _liveUpdate = false;
  bool _permission = false;

  String? _serviceError = '';

  var interActiveFlags = InteractiveFlag.all;


  final geo.Location _locationService = geo.Location();
  //geolocator
  Future<geolocator.Position> _determinePosition() async {
    bool serviceEnabled;
    geolocator.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await geolocator.Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await geolocator.Geolocator.getCurrentPosition();
  }

  Future<void> GetAddressFromLatLong(geolocator.Position position ) async{
    List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
  }
  List _list = [
    [
      "Ferensay Taxi Station",
      ["9.055598"],
      ["38.7739939"]
                    ],
                    [
                      "Gerji Megnagna",
                      ["9.000577278890313"],
                      ["38.810415108969956"]
                    ],
                    [
                      "Gerji Bole",
                      ["8.996607374412472"],
                      ["38.80892243952237"]

                    ],
                    [
                      "Churchil Taxi Station",
                      ["9.042270362431195"],
                      ["38.74999015396373"]
                    ],
                    [
                      "Megenagna Taxi Station",
                      ["9.011926934609333"],
                      ["38.74761685554566"]
                    ],
                    [
                      "Bole 4 kilo Taxi Station",
                      ["9.01167179285996"],
                      ["38.74770267704092"]
                    ],
                    [
                      "Bulbula Condominium Taxi Station",
                      ["8.954328992603463"],
                      ["38.7858178553648"]
                    ],
                    [
                      "Ankorcha Taxi Station",
                      ["9.0621190706066"],
                      ["38.802022123679954"]
                    ],
                    [
                      "Cherkos square Taxi/Bus Station",
                      ["8.975042442424103"],
                      ["38.88966631675065"]
                    ],
                    [
                      "Ayer Tena Taxi Station",
                      ["8.985490251290186"],
                      ["38.697065323679944"]
                    ],
                    [
                      "Jemo Taxi Station",
                      ["8.96215132682134"],
                      ["38.71174387813652"]
                    ],
                    [
                      "Sumit Condominium 3 taxi station",
                      ["8.98625248056642"],
                      ["38.85528569298702"]
                    ],
                    ];
                    //[Ferensay:["9.055598","38.7739939"], 'Japanese Textbook', 'English Vocabulary', 'Japanese Vocabulary'];
                    getLocation() async {
              Position position = await geolocator.Geolocator.getCurrentPosition(
              desiredAccuracy: geolocator.LocationAccuracy.high);
              print(position.longitude);
              print(position.latitude);

              }
                  @override
                  void initState() {
    super.initState();
    getLocation();
    _mapController = MapController();
    initLocationService();
    _determinePosition();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double>();
    }
        @override
        void dispose() {
      _centerCurrentLocationStreamController.close();
      super.dispose();
    }

    void initLocationService() async {
      await _locationService.changeSettings(
        // accuracy: LocationAccuracy.high,
        interval: 1000,
      );

      geo.LocationData? location;
      bool serviceEnabled;
      bool serviceRequestResult;

      try {
        serviceEnabled = await _locationService.serviceEnabled();

        if (serviceEnabled) {
          var permission = await _locationService.requestPermission();
          _permission = permission == geo.PermissionStatus.granted;

          if (_permission) {
            location = await _locationService.getLocation();
            _currentLocation = location;
            _locationService.onLocationChanged
                .listen((geo.LocationData result) async {
              if (mounted) {
                setState(() {
                  _currentLocation = result;

                  // If Live Update is enabled, move map center
                  if (_liveUpdate) {
                    _mapController.move(
                        LatLng(_currentLocation!.latitude!,
                            _currentLocation!.longitude!),
                        _mapController.zoom);
                  }
                });
              }
            });
          }
        } else {
          serviceRequestResult = await _locationService.requestService();
          if (serviceRequestResult) {
            initLocationService();
            return;
          }
        }
      } catch (e) {
        print(e);
      }
    }

    getItemAndNavigate(String item, BuildContext context) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SecondScreen(itemHolder: item)));
    }

    Widget _searchListView() {
      return ListView.builder(
          itemCount: _searchIndexList.length,
          itemBuilder: (context, index) {
            index = _searchIndexList[index];
            return Card(
                child: ListTile(
                  title: Text(_list[index]![0]),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => detailPage(itemHolder: _list[index],)));
                  },
                ));
          });
    }

    Widget _defaultListView() {
      // String route = 'home';
      LatLng currentLatLng;

      // // Until currentLocation is initially updated, Widget can locate to 0, 0
      // // by default or store previous location value to show.
      if (_currentLocation != null) {
        currentLatLng =
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      } else {
        currentLatLng = LatLng(0, 0);
      }

      // var markers = <Marker>[
      //   Marker(
      //     width: 80.0,
      //     height: 80.0,
      //     point: currentLatLng,
      //     builder: (ctx) => Container(
      //       child: Icon(
      //         Icons.location_on,
      //         color: Colors.red,
      //       ),
      //     ),
      //   ),
      // ];
      return Scaffold(
        // appBar: AppBar(title: Text('Map inside ListView')),
        // drawer: buildDrawer(context, MapInsideListViewPage.route),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: _serviceError!.isEmpty
                    ? Text('This is a map that is showing '
                    '(${currentLatLng.latitude}, ${currentLatLng.longitude}).')
                    : Text(
                    'Error occured while acquiring location. Error Message : '
                        '$_serviceError'),
              ),
              Container(
                height: 300,
                child: FlutterMap(
                  mapController: _mapController,

                  options: new MapOptions(
                      // center: new LatLng(9.0620129, 38.7406542),
                      minZoom: 10.0,
                      interactiveFlags: interActiveFlags,
                      // plugins: [
                      //   LocationMarkerPlugin(),
                      // ],
                      onPositionChanged: (MapPosition position, bool hasGesture) {
                        if (hasGesture) {
                          setState(() => _centerOnLocationUpdate = CenterOnLocationUpdate.never);
                        }
                      }
                  ),


                  children : [
                    TileLayerWidget(
                      options: TileLayerOptions(
                          urlTemplate: 'https://api.mapbox.com/styles/v1/gedlekiristos/ckye626kj5l9v14s8axk9hj9g/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2VkbGVraXJpc3RvcyIsImEiOiJja3hyZ3M5cGEwMmlwMm9vNWJmNG02MDFoIn0.PBHcecjt5JQaOUmsqdgU1g',
                          additionalOptions: {
                            'accessToken': 'pk.eyJ1IjoiZ2VkbGVraXJpc3RvcyIsImEiOiJja3hyZ3M5cGEwMmlwMm9vNWJmNG02MDFoIn0.PBHcecjt5JQaOUmsqdgU1g',
                            'id' : 'mapbox.mapbox-streets-v8'
                          }

                      ),
                    ),
                    TappablePolylineLayerWidget(
                      options: TappablePolylineLayerOptions(
                        polylineCulling: true,
                        polylines: [
                        ],
                          onTap: (polylines, tapPosition) => print('Tapped: ' +
                              polylines.map((polyline) => polyline.tag).join(',') +
                              ' at ' +
                              tapPosition.globalPosition.toString()),
                          onMiss: (tapPosition) {
                            print('No polyline was tapped at position ' +
                                tapPosition.globalPosition.toString());
                          }

                      ),
                    ),
                    LocationMarkerLayerWidget(
                      options: LocationMarkerLayerOptions(
                        marker: DefaultLocationMarker(
                          color: Colors.grey,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                        markerSize: const Size(40, 40),
                        accuracyCircleColor: Colors.white.withOpacity(0.1),
                        headingSectorColor: Colors.white.withOpacity(0.8),
                        headingSectorRadius: 120,
                        markerAnimationDuration: Duration.zero,
                      ),
                      plugin: LocationMarkerPlugin(
                        centerCurrentLocationStream: _centerCurrentLocationStreamController.stream,
                        centerOnLocationUpdate: _centerOnLocationUpdate,

                      ),

                    ),


                    // new PolylineLayerWidget(
                    //   options: PolylineLayerOptions(
                    //       polylines: [
                    //         new Polyline(
                    //           points: points,
                    //           color: Colors.red
                    //         )
                    //
                    //       ]
                    //   ),
                    //
                    // ),

                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Where Would you like to go today ?'),

                    ),
                    ListTile(
                      leading: Icon(Icons.local_taxi ,color: Colors.black,),
                      title: const Text('Taxi'),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.directions_bus , color: Colors.black,),
                      title: const Text('BUS'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(onPressed: () async{
                geolocator.Position position = await _determinePosition();
                print(position.latitude);

                location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
                GetAddressFromLatLong(position);
                setState(() {

                });
              },
                  child: Text('Get Location')),
              Text(
                '${location}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 500),
              Card(child: ListTile(title: Text('look at that scrolling')))
            ],
          ),
        ),
        floatingActionButton: Builder(builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () {
              // setState(() {
              //   _liveUpdate = !_liveUpdate;
              //
              //   if (_liveUpdate) {
              //     interActiveFlags = InteractiveFlag.rotate |
              //         InteractiveFlag.pinchZoom |
              //         InteractiveFlag.doubleTapZoom;
              //
              //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //       content: Text(
              //           'In live update mode only zoom and rotation are enable'),
              //     ));
              //   } else {
              //     interActiveFlags = InteractiveFlag.all;
              //   }
              // });
              setState(() => _centerOnLocationUpdate = CenterOnLocationUpdate.always);
              // Center the location marker on the map and zoom the map to level 18.
              _centerCurrentLocationStreamController.add(18);
            },
            // child: _liveUpdate
            //     ? Icon(Icons.my_location)
            //     : Icon(Icons.location_off),
            child: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          );
        },
        ),
    );
  }

  Widget _searchTextField() {
    return TextField(
      onChanged: (String s) {
        setState(() {
          _searchIndexList = [];
          print(_list[0][0]);
          print(_list[0][2]);
          for (int i = 0; i < _list.length; i++) {
            if (_list[i]![0].contains(s)) {
              print(_list[i]![0]);
              _searchIndexList.add(i);
            }
          }
        });
      },
      autofocus: true,
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintText: 'Search',
        hintStyle: TextStyle(
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LatLng currentLatLng;

    return Scaffold(
        appBar: AppBar(
            title: !_searchBoolean ? Text(widget.title) : _searchTextField(),
            actions: !_searchBoolean
                ? [
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _searchBoolean = true;
                            _searchIndexList = [];
                          });
                        })
                  ]
                : [
                    IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchBoolean = false;
                          });
                        })
                  ]),
        body: !_searchBoolean ? _defaultListView() : _searchListView());
  }
}

class SecondScreen extends StatelessWidget {
  final String itemHolder;

  SecondScreen({Key? key, required this.itemHolder}) : super(key: key);

  goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Second Activity Screen"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                'Selected Item = ' + itemHolder,
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              )),
              // ignore: deprecated_member_use
              RaisedButton(
                onPressed: () {
                  goBack(context);
                },
                color: Colors.lightBlue,
                textColor: Colors.white,
                child: Text('Go Back To Previous Screen'),
              )
            ]));
  }
}
