
import 'dart:convert';
import 'dart:io';

import 'package:QRLock/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/ui/views/base/generate_page.dart';
import 'package:map_controller/map_controller.dart';

//Generate Location QR Code
class GenerateLocationQRCode extends GeneratePage {
  GenerateLocationQRCode({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _GenerateLocationQRCodeState createState() {
    return _GenerateLocationQRCodeState();
  }
}

class _GenerateLocationQRCodeState extends GenerateState {
  TextEditingController _passwordController = TextEditingController();

  bool _isEncrypted = false;
  bool _obscureText = true;

  LatLng userLocation;
  final _formKey = GlobalKey<FormState>();
  MapController _mapController;
  StatefulMapController statefulMapController;
  LatLng selectedPosition;
  StatefulMarker marker;
  File _image;
  void getImage() {
    ImagePickerGC.pickImage(
      context: context,
      source: ImgSource.Both,
      cameraIcon: Icon(
        Icons.camera,
      ),
      galleryIcon: Icon(
        Icons.image,
      ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    ).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

// Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText; //toggle password visibility
    });
  }


  //Submit entered data
  @override
  QRCodeData submit() {
    //Check that the user selected a position on the map
    if (this.selectedPosition != null) {
      if (_formKey.currentState.validate()) {
        // If the form is valid, produce the QR code
        QRCodeData qrCodeData = QRCodeData(
          generatedOrHistory: 1,
          date: DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now()),
          geoLat: this.selectedPosition.latitude.toString(),
          geoLng: this.selectedPosition.longitude.toString(),
          qrCodeType: QRCodeType.GEO_LOCATION,
          password: _passwordController.text,
          qrEncryptionType: _isEncrypted
              ? QREncryptionType.ENCRYPTED
              : QREncryptionType.PLAIN,
          image: _image != null ? base64Encode(_image.readAsBytesSync()) : null,
        );
        return qrCodeData;
      }
    } else {
      //If he didn't show a dialog asking him to select a location
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Geo location is missing'),
              content: Text("Please select a location on the map."),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
    return null;
  }

  @override
  void initState() {

    _mapController = MapController(); //Normal map controller
    statefulMapController = StatefulMapController(
        mapController:
            _mapController); //Create a stateful map controller to be able
    // to be able to add and remove the marker and get it's location
    //this map controller also requires a normal map controller
    //the map controller that is attached to map view
    // wait for the controller to be ready before using it
    statefulMapController.onReady
        .then((_) => print("The map controller is ready"));

    /// [Important] listen to the changefeed to rebuild the map on changes:
    /// this will rebuild the map when for example addMarker or any method
    /// that mutates the map assets is called
    // Get current user location and add marker to map
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      if (value != null) {
        this.userLocation =
            new LatLng(value.latitude, value.longitude); //User Location
        this.selectedPosition =
            this.userLocation; //The position the user selects with the marker
        _addMarker(); //Add marker
        statefulMapController
            .centerOnPoint(this.userLocation); //Center map on user location
      }
    });
    super.initState();
  }

  //Adds marker where selectedPosition variable points
  void _addMarker() {
    setState(() {
      statefulMapController.addMarker(
          marker: Marker(
              point: selectedPosition,
              builder: (BuildContext context) {
                return Icon(Icons.location_on);
              }),
          name: "pos");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        child: Form(
          key: _formKey,
          child: Padding(
              padding: EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          child: Checkbox(
                            value: _isEncrypted,
                            onChanged: (newValue) {
                              setState(() {
                                _isEncrypted = newValue;
                              });
                            },
                          ),
                          width: 24,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(hintText: 'Password'),
                          validator: (val) => _isEncrypted && val.length < 6
                              ? 'Password too short.'
                              : null,
                          enabled: _isEncrypted,
                          obscureText: _obscureText,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                            child: IconButton(
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                _toggle();
                              },
                            ),
                            width: 20,
                          )),
                    ],
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height / 2 - 50,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: new MapOptions(
                            zoom: 17.0,
                            onTap: (LatLng pos) {
                              statefulMapController.removeMarker(name: "pos");
                              this.selectedPosition = pos;
                              _addMarker();
                            }),
                        layers: [
                          new TileLayerOptions(
                            urlTemplate:
                                "https://www.google.com/maps/vt/pb=!1m4!1m3!1i{z}!2i{x}!3i{y}!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425",
                          ),
                          MarkerLayerOptions(
                              markers: statefulMapController.markers),
                          PolylineLayerOptions(
                              polylines: statefulMapController.lines),
                          PolygonLayerOptions(
                              polygons: statefulMapController.polygons)
                        ],
                      )),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RaisedButton(
                          onPressed: () {
                            getImage();
                          },
                          shape: StadiumBorder(),
                          color: AppTheme.nearlyBlue,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Choose Image",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      _image != null
                          ? Image(
                              width: 100.0,
                              image: FileImage(
                                _image,
                                scale: 0.2,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
