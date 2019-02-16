import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_coffee_app/api/CoffeeShopsApi.dart';
import 'package:my_coffee_app/api/MyLocationApi.dart';
import 'package:my_coffee_app/model/CoffeeShopsData.dart';
import 'package:my_coffee_app/model/MyLocationData.dart';

class MyMapPage extends StatefulWidget {
  MyMapPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyMapPageState createState() => new _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {

  CameraPosition _kInitialPosition;
  GoogleMapController mapController;
  static MyLocationData _myLocationData;
  CoffeeShopsData _shops;

  Future<CoffeeShopsData> _getCoffeeShops() async {
    final shopsApi = CoffeeShopsApi.getInstance();
    return await shopsApi.getCoffeeShops(_myLocationData);
  }

  Future<MyLocationData> _getLocation() async {
    final locationApi = MyLocationApi.getInstance();
    return await locationApi.getLocation();
  }

  @override
  void initState() {
    super.initState();

    _getLocation().then((location) {
      setState(() {
        _myLocationData = location;
        _kInitialPosition = CameraPosition(
          target: LatLng(
            _myLocationData.lat,
            _myLocationData.lon,
          ),
          zoom: 14,
        );
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) async{
    _shops = await _getCoffeeShops();
    setState(() {
      mapController = controller;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: _myLocationData != null ? SizedBox(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kInitialPosition,
          ),
        ) : CircularProgressIndicator(
          strokeWidth: 4.0,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    );
  }
}
