import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapps extends StatelessWidget {
  final String id;
  Mapps(this.id);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Map(id),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Map extends StatefulWidget {
  final String id;
  Map(this.id);
  @override
  _MapState createState() => _MapState(id);
}

class _MapState extends State<Map> {
  final String id;
  var data;
  var lat, lng;
  _MapState(this.id);

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(45.521569, -122.677433);
  final databaseReference = FirebaseDatabase.instance.reference();

  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  static final CameraPosition _position1 = CameraPosition(
      bearing: 192.833,
      target: LatLng(45.5315, -122.677433),
      tilt: 59.440,
      zoom: 11.0);
  Future<void> _gotoPosition1() async {
    CameraPosition _po1 = CameraPosition(
        bearing: 192.833, target: LatLng(lat, lng), tilt: 59.440, zoom: 18.0);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_po1));
  }

  void initState() {
    super.initState();
    databaseReference
        .child('locations/' + id)
        .once()
        .then((DataSnapshot snapshot) {
      lng = snapshot.value['longitude'];
      lat = snapshot.value['latitude'];
      LatLng position = LatLng(lat, lng);
      _onAddMarkerButton(position);
      data = snapshot.value;
    });
    databaseReference
        .child('locations/' + id)
        .onChildAdded
        .listen(_onEntryAdded);
    databaseReference
        .child('locations/' + id)
        .onChildChanged
        .listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    if (!mounted) return;

    if (event.snapshot.key == "latitude") {
      setState(() {
        lat = event.snapshot.value;
        LatLng position = LatLng(lat, lng);
        _onAddMarkerButton(position);
      });
    }
    if (event.snapshot.key == "longitude") {
      setState(() {
        lng = event.snapshot.value;
        LatLng position = LatLng(lat, lng);
        _onAddMarkerButton(position);
      });
    }
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

  _ChangePosi(position) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition _position1 = CameraPosition(
        bearing: 192.833, target: position, tilt: 0.440, zoom: 20.0);
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
    _ChangePosi(position);
  }

  Pocess() {
    LatLng position = LatLng(26.676913, 64.440629);
    _onAddMarkerButton(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text(id)),
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
                  button(_onMapTypePressed, Icons.map, '123123'),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_gotoPosition1, Icons.location_searching, 'asdsad2e')
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget button(Function function, IconData icon, String a) {
    return FloatingActionButton(
      heroTag: a,
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
