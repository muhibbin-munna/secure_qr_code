import 'dart:io';

import 'package:QRLock/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:r_scan/r_scan.dart';

class RScanCameraDialog extends StatefulWidget {
  final List<RScanCameraDescription> rScanCameras;

  const RScanCameraDialog({Key key, this.rScanCameras}) : super(key: key);
  @override
  _RScanCameraDialogState createState() => _RScanCameraDialogState();
}

class _RScanCameraDialogState extends State<RScanCameraDialog> {
  RScanCameraController _controller;
  bool isFirst = true;
  BuildContext mContext;
  File _image;
  void getImage() {
    ImagePickerGC.pickImage(
      context: context,
      source: ImgSource
          .Gallery, //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    ).then((image) async {
      _image = image;
      final result = await RScan.scanImageMemory(_image.readAsBytesSync());
      if (isFirst) {
        Utils().decodeQrCode(result.message, mContext,
            soundEffects: true, save: true);
        //Navigator.of(mContext).pop(result);
        isFirst = false;
      }
    });
  }

  @override
  void initState() {
    isFirst = true;
    mContext = context;
    if (widget.rScanCameras != null && widget.rScanCameras.length > 0) {
      _controller = RScanCameraController(
          widget.rScanCameras[0], RScanCameraResolutionPreset.max)
        ..addListener(() {
          final result = _controller.result;
          if (result != null) {
            if (isFirst) {
              Utils().decodeQrCode(result.message, mContext,
                  soundEffects: false, save: true);
              //Navigator.of(mContext).pop(result);
              isFirst = false;
            }
          }
        })
        ..initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
    }


    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rScanCameras == null || widget.rScanCameras.length == 0) {
      return Scaffold(
        body: Container(),
      );
    }
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: RScanCamera(_controller),
            ),
          ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FutureBuilder(
                  future: getFlashMode(),
                  builder: _buildFlashBtn,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left:50.0, bottom: 24),
                  child: IconButton(
                    icon: Icon(Icons.photo, color: Colors.white,),
                    onPressed: () {
                      getImage();
                    },
                    iconSize: 46.0,
                  ),
                ),
              ),
          Positioned(
              top: 20,
              left: 0,
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })),
        ],
      ),
    );
  }

  Future<bool> getFlashMode() async {
    bool isOpen = false;
    try {
      isOpen = await _controller.getFlashMode();
    } catch (_) {}
    return isOpen;
  }

  Widget _buildFlashBtn(BuildContext context, AsyncSnapshot<bool> snapshot) {
    return snapshot.hasData
        ? Padding(
            padding: EdgeInsets.only(
                right:50, bottom: 24 + MediaQuery.of(context).padding.bottom),
            child: IconButton(
                icon: Icon(snapshot.data ? Icons.flash_on : Icons.flash_off),
                color: Colors.white,
                iconSize: 46,
                onPressed: () {
            if (snapshot.data) {
              _controller.setFlashMode(false);
            } else {
              _controller.setFlashMode(true);
            }
            setState(() {});
                }),
          )
        : Container();
  }
}
