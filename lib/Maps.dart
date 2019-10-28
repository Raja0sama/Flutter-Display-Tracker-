import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Map(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521569, -122.677433);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  static final CameraPosition _position1 = CameraPosition(
      bearing: 192.833,
      target: LatLng(45.5315, -122.677433),
      tilt: 59.440,
      zoom: 11.0);
  Future<void> _gotoPosition1() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onMapTypePressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
   
  }

  _ChangePosi(position) async{
final GoogleMapController controller = await _controller.future;
      CameraPosition _position1 = CameraPosition(
          bearing: 192.833, target: position, tilt: 59.440, zoom: 9.0);
      controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }
  _onAddMarkerButton(position) {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("Hellow"),
          position: position,
          infoWindow: InfoWindow(
            title: 'This the title',
            snippet: 'this is a snippet',
          ),
          icon: BitmapDescriptor.defaultMarker));
    });
    _ChangePosi(position);
  }

  Pocess(){
       LatLng position =  LatLng(26.676913, 64.440629);
    _onAddMarkerButton(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('Map')),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
            mapType: _currentMapType,
            markers: _markers,
            onCameraMove: _onCameraMove,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  button(_onMapTypePressed, Icons.map),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(Pocess, Icons.add_location),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_gotoPosition1, Icons.location_searching)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 16,
      ),
    );
  }
}
