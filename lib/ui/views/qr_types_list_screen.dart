import 'package:QRLock/ui/views/generateQRCodeScreens/generateCryptoQRCode.dart';
import 'package:QRLock/ui/views/generateQRCodeScreens/generateWhatsAppQRCode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/ads.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/ui/views/base/generate_page.dart';
import 'package:QRLock/ui/views/generate_overlay.dart';
import 'package:QRLock/ui/views/view_qr_code_overlay.dart';
import 'package:QRLock/ui/widgets/appBar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/app_theme.dart';
import 'generateQRCodeScreens/generateLocationQRCode.dart';
import 'generateQRCodeScreens/generateSMSQRCodeScreen.dart';
import 'generateQRCodeScreens/generateTextQRCode.dart';

//Screen where we show all the types, click on one of them to generate
class QRTypesList extends StatefulWidget {
  const QRTypesList({Key key}) : super(key: key);

  @override
  _QRTypesListState createState() => _QRTypesListState();
}

class _QRTypesListState extends State<QRTypesList>
    with TickerProviderStateMixin {
  List<QRTypeListItem> homeList;

  //Animation controller to animate the grid items in
  AnimationController animationController;

  //Animation controller for showing the generate overlay
  AnimationController overlayAnimationController;

  //Animation controller for showing the view qr code overlay
  AnimationController viewQRCodeOverlayAnimationController;
  bool multiple = true;

  //If the generate overlay is visible
  bool overlayVisible = false;

  //If the view QR code overlay is visible
  bool viewQROverlay = false;

  //If the background blur is visible
  bool blurVisible = false;

  //Generate overlay widget
  Widget overlayWidget;

  //View QR code overlay data
  QRCodeData overlayData;
  ThemeData theme;

  //The key which we will pass to the Generate Page to get its state and call the submit function
  final contentKey = GlobalKey<GenerateState>();

  @override
  void initState() {
    Ads().showAd();
    homeList = getQRTypesListItems();
    animationController = AnimationController(
        duration: Duration(milliseconds: Configuration.animationTime),
        vsync: this);
    overlayAnimationController = AnimationController(
      duration: Duration(milliseconds: Configuration.animationTime),
      vsync: this,
    );
    viewQRCodeOverlayAnimationController = AnimationController(
      duration: Duration(milliseconds: Configuration.animationTime),
      vsync: this,
    );
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  //return all the QR Code types and their screens
  //function to generate all list items in the screen, one for each QR code type
  List<QRTypeListItem> getQRTypesListItems() {
    List<QRTypeListItem> list = [];
    list.add(QRTypeListItem(
        'assets/text.png',
        GenerateTextQRCode(
          title: "Text",
          qrCodeType: QRCodeType.TEXT,
          key: contentKey,
        ),
        QRCodeType.TEXT));
    list.add(QRTypeListItem(
        'assets/call.png',
        GenerateTextQRCode(
          title: "Phone Number",
          qrCodeType: QRCodeType.PHONE_NUMBER,
          key: contentKey,
        ),
        QRCodeType.PHONE_NUMBER));
    list.add(QRTypeListItem(
        'assets/web.png',
        GenerateTextQRCode(
          title: "URL",
          qrCodeType: QRCodeType.WEB,
          key: contentKey,
        ),
        QRCodeType.WEB));
    list.add(QRTypeListItem(
      'assets/location.png',
      GenerateLocationQRCode(
        title: "Location",
        key: contentKey,
      ),
      QRCodeType.GEO_LOCATION,
    ));
    list.add(QRTypeListItem(
        'assets/email.png',
        GenerateTextQRCode(
          title: "Email",
          qrCodeType: QRCodeType.EMAIL,
          key: contentKey,
        ),
        QRCodeType.EMAIL));
    list.add(QRTypeListItem(
        'assets/sms.png',
        GenerateSMSQRCode(
          key: contentKey,
        ),
        QRCodeType.SMS));
    list.add(QRTypeListItem(
        'assets/whats.png',
        GenerateWhatsAppQRCode(
          key: contentKey,
        ),
        QRCodeType.WHATSAPP));
    list.add(QRTypeListItem(
        'assets/youtube.png',
        GenerateTextQRCode(
          key: contentKey,
          qrCodeType: QRCodeType.YOUTUBE,
        ),
        QRCodeType.YOUTUBE));
    list.add(QRTypeListItem(
        'assets/bitcoin.png',
        GenerateCryptoQRCode(
          qrCodeType: QRCodeType.BITCOIN,
          key: contentKey,
        ),
        QRCodeType.BITCOIN));
    list.add(QRTypeListItem(
        'assets/ethereum.png',
        GenerateCryptoQRCode(
          qrCodeType: QRCodeType.ETHEREUM,
          key: contentKey,
        ),
        QRCodeType.ETHEREUM));

    return list;
  }

  //Gets black overlay
  Widget getBlur() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.5),
    );
  }

  //Gets the generate overlay to put in a stack
  Widget getOverlay({GeneratePage content}) {
    return Positioned(
      bottom: -600,
      child: Visibility(
        visible: overlayVisible,
        child: AnimatedBuilder(
          animation: overlayAnimationController,
          child: GenerateOverlay(
            content: content != null ? content : Container(),
            onSubmitTap: () {
              if (content != null) {
                QRCodeData data = contentKey.currentState.submit();
                print(data);
                if (data != null) {
                  dismissOverlay();
                  setState(() {
                    overlayData = data;
                    viewQROverlay = true;
                    blurVisible = true;
                  });
                  viewQRCodeOverlayAnimationController.forward();
                }
              }
            },
            onCancelTap: () {
              dismissOverlay();
            },
          ),
          builder: (BuildContext context, Widget child) {
            return Transform(
                transform: Matrix4.translationValues(
                    0, overlayAnimationController.value * -600, 0),
                child: child);
          },
        ),
      ),
    );
  }

  Widget getViewQRCodeOverlay({QRCodeData content}) {
    if (content != null)
      return Positioned(
        bottom: -600,
        child: Visibility(
          visible: viewQROverlay,
          child: AnimatedBuilder(
            animation: viewQRCodeOverlayAnimationController,
            child: ViewQRCodeOverlay(
              content: content,
              onCancelTap: () {
                dismissQRCodeOverlay();
              },
              save: true,
            ),
            builder: (BuildContext context, Widget child) {
              return Transform(
                  transform: Matrix4.translationValues(
                      0, viewQRCodeOverlayAnimationController.value * -600, 0),
                  child: child);
            },
          ),
        ),
      );
    else
      return Container();
  }

  void dismissOverlay() {
    if (!overlayAnimationController.isAnimating)
      setState(() {
        blurVisible = false;
      });
    overlayAnimationController.reverse().then((value) {
      setState(() {
        overlayVisible = false;
        overlayWidget = null;
      });
    });
    if (viewQROverlay) {
      dismissQRCodeOverlay();
    }
  }

  void dismissQRCodeOverlay() {
    if (!viewQRCodeOverlayAnimationController.isAnimating)
      setState(() {
        blurVisible = false;
      });
    viewQRCodeOverlayAnimationController.reverse().then((value) {
      setState(() {
        viewQROverlay = false;
        overlayData = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.notWhite,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: Stack(
            children: [
              FutureBuilder<bool>(
                future: getData(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              appBar('Select Type'),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder<bool>(
                              future: getData(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<bool> snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox();
                                } else {
                                  return GridView(
                                    padding: const EdgeInsets.only(
                                        top: 12,
                                        left: 12,
                                        right: 12,
                                        bottom: 10),
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    children: List<Widget>.generate(
                                      homeList.length,
                                      (int index) {
                                        final int count = homeList.length;
                                        final Animation<double> animation =
                                            Tween<double>(begin: 0.0, end: 1.0)
                                                .animate(
                                          CurvedAnimation(
                                            parent: animationController,
                                            curve: Interval(
                                                (1 / count) * index, 1.0,
                                                curve: Curves.fastOutSlowIn),
                                          ),
                                        );
                                        animationController.forward();
                                        return HomeListView(
                                          animation: animation,
                                          animationController:
                                              animationController,
                                          listData: homeList[index],
                                          callBack: () {
                                            if (!overlayVisible) {
                                              setState(() {
                                                blurVisible = true;
                                                overlayVisible = true;
                                                overlayWidget =
                                                    homeList[index].generator;
                                                overlayAnimationController
                                                    .forward();
                                              });
                                            } else {
                                              dismissOverlay();
                                            }
                                            // Fluttertoast.showToast(
                                            //     msg: index.toString(),
                                            //     toastLength: Toast.LENGTH_SHORT,
                                            //     gravity: ToastGravity.CENTER,
                                            //     timeInSecForIosWeb: 1,
                                            //     backgroundColor: Colors.red,
                                            //     textColor: Colors.white,
                                            //     fontSize: 16.0);
                                          },
                                        );
                                      },
                                    ),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: multiple ? 2 : 1,
                                      mainAxisSpacing: 12.0,
                                      crossAxisSpacing: 15.0,
                                      childAspectRatio: 1.5,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              GestureDetector(
                onTap: () {
                  if (overlayVisible) {
                    dismissOverlay();
                  }
                },
                child: Visibility(
                  child: getBlur(),
                  visible: blurVisible,
                ),
              ),
              getOverlay(content: overlayWidget),
              getViewQRCodeOverlay(content: overlayData)
            ],
          ),
        ),
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  const HomeListView(
      {Key key,
      this.listData,
      this.callBack,
      this.animationController,
      this.animation})
      : super(key: key);

  final QRTypeListItem listData;
  final VoidCallback callBack;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          width: (MediaQuery.of(context).size.width),
                          child: Stack(
                            overflow: Overflow.clip,
                            children: [
                              Positioned(
                                left: 10,
                                top: 10,
                                bottom: 10,
                                right: 10,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image(
                                      image: AssetImage(listData.imagePath),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.grey.withOpacity(0.2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0)),
                            onTap: () {
                              callBack();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[300],
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[600],
                          offset: Offset(4.0, 4.0),
                          blurRadius: 15.0,
                          spreadRadius: 1.0),
                      BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4.0, -4.0),
                          blurRadius: 15.0,
                          spreadRadius: 1.0),
                    ],
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[200],
                          Colors.grey[300],
                          Colors.grey[400],
                          Colors.grey[500],
                        ],
                        stops: [
                          0.1,
                          0.3,
                          0.8,
                          1
                        ]),
                  )),
            ),
          ),
        );
      },
    );
  }
}

// class that encapsulate any QR type list item
class QRTypeListItem {
  String title;
  GeneratePage generator;
  QRCodeType qrCodeType;

  String imagePath;

  QRTypeListItem(this.imagePath, this.generator, this.qrCodeType);
}
