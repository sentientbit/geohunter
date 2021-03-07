/// IAP https://www.youtube.com/watch?v=NWbkKH-2xcQ
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
// Admob variant 1 :(
import 'package:admob_flutter/admob_flutter.dart';
// Admob variant 2 :(
//import 'package:firebase_admob/firebase_admob.dart';
// Admob variant 3 :(
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../app_localizations.dart';
// import 'package:logger/logger.dart';

///
import '../../models/user.dart';
import '../../providers/api_provider.dart';
import '../../providers/custom_interceptors.dart';
import '../../providers/stream_userdata.dart';
import '../../screens/inventory/blueprints.dart';
import '../../screens/inventory/materials.dart';
import '../../shared/constants.dart';
import '../../text_style.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/drawer.dart';

///
enum PopupMenuChoice { refreshForge, showCoinSheet }

///
class ForgePage extends StatefulWidget {
  ///
  final String name = 'forge';

  @override
  _ForgeState createState() => _ForgeState();
}

///
class _ForgeState extends State<ForgePage> {
  final _userdata = getIt.get<StreamUserData>();

  /// Secure Storage for User Data
  final _storage = FlutterSecureStorage();

  final InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  StreamSubscription _subscription;

  bool _isIapAvailable = false;

  List<ProductDetails> _iapProducts = [];

  List<String> _productIds = ["gold11coins", "", ""];
  List<String> _productDescriptions = ["", "", ""];
  List<String> _productPrices = ["", "", ""];

  List<PurchaseDetails> _purchases = [];

  bool _showCoinSheet = false;

  int _blueprintId = 0;
  String _blueprintImg = "";
  String _blueprintName = "";

  List<int> _materialsId = [0, 0, 0];
  List<String> _materialsImg = ["", "", ""];
  List<String> _materialsName = ["", "", ""];

  String _craftedItemImg = "";
  String _craftedItemName = "";

  /// Curent loggedin user
  User _user;

  /// Validation token is used to sign every purchase transaction on the API
  String _validationToken = '';

  /// Transaction Id has to match the database token
  int _transactionId = 0;

  // Admob variant 1 :(
  AdmobReward _admobAdvert;

  bool _isLoading = false;
  bool _isRewarded = false;
  bool _adLoaded = false;
  String _admobType;
  int _admobAmount;

  // final Logger log = Logger(
  //     printer: PrettyPrinter(
  //         colors: true, printEmojis: true, printTime: true, lineLength: 80));

  ///
  final ApiProvider _apiProvider = ApiProvider();

  /// Make sure back button is pressed twice
  bool ifPop = false;

  ///
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _getPlacements();
    _getUserDetails();

    // Admob variant 1 :(
    _admobAdvert = AdmobReward(
      adUnitId: AdManager.rewardedAdUnitId,
      listener: (event, args) {
        if (event == AdmobAdEvent.loaded) {
          print('--- AdmobReward loaded');
          _admobAdvert.show();
          setState(() {
            _isRewarded = false;
          });
        } else if (event == AdmobAdEvent.closed) {
          print('--- AdmobReward closed');
          _admobAdvert.dispose();
          if (_isRewarded) {
            _serverReward(null);
          } else {
            showDialog(
              context: context,
              builder: (context) => CustomDialog(
                title: 'Info',
                description: "You have to watch the whole commercial "
                    "to get the materials from that point",
                buttonText: "Okay",
              ),
            );
          }
          _isRewarded = false;
          setState(() {
            _admobType = "";
            _isLoading = false;
          });
        } else if (event == AdmobAdEvent.rewarded) {
          print('--- AdmobReward rewarded');
          _admobType = "Reward";
          _isRewarded = true;
          setState(() {
            _admobAmount += args['amount'];
            _isLoading = false;
          });
        } else if (event == AdmobAdEvent.failedToLoad) {
          print('--- AdmobReward failed');
          _isRewarded = false;
          showDialog(
            context: context,
            builder: (context) => CustomDialog(
              title: 'Error',
              description: Platform.isAndroid
                  ? "Google Mobile Ads failed. Please try again later."
                  : "Apple Mobile Ads failed. Please try again later.",
              buttonText: "Okay",
            ),
          );
          _deleteReward();
          _admobAdvert.dispose();
          setState(() {
            _isLoading = false;
          });
        }
      },
    );

    BackButtonInterceptor.add(
      myInterceptor,
      name: widget.name,
      context: context,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    BackButtonInterceptor.remove(myInterceptor);
    _admobAdvert?.dispose();
    super.dispose();
  }

  // ignore: avoid_positional_boolean_parameters
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (stopDefaultButtonEvent) return false;
    if (ifPop) {
      return false;
    } else {
      setState(() => ifPop = true);
      if (_scaffoldKey != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(GlobalConstants.backButtonPage);
      }
    }
    return true;
  }

  void _initializeIAP() async {
    // Check IAP availability
    _isIapAvailable = await _iap.isAvailable();

    if (_isIapAvailable) {
      await _getProducts();

      _subscription = _iap.purchaseUpdatedStream.listen((data) {
        setState(() {
          _purchases.addAll(data);
          _isLoading = false;
        });
        //print('NEW PURCHASE');
        _callbackPurchase();
      });
    }
  }

  /// Return purchase of specific product ID
  PurchaseDetails _hasPurchased(String productId) {
    return _purchases.firstWhere((element) => element.productID == productId,
        orElse: () => null);
  }

  void _callbackPurchase() {
    //ignore: omit_local_variable_types
    PurchaseDetails purchase = _hasPurchased(_productIds[0]);
    if (purchase == null) {
      //print('PurchaseStatus.null');
      _deleteReward();
      return;
    }
    if (purchase.status == PurchaseStatus.purchased) {
      //print('PurchaseStatus.purchased');
      _serverReward(purchase);
    } else if (purchase.status == PurchaseStatus.error) {
      //print('PurchaseStatus.error');
      _deleteReward();
    }
  }

  Future<void> _getProducts() async {
    //ignore: omit_local_variable_types
    Set<String> ids = Set.from([_productIds[0]]);

    //ignore: omit_local_variable_types
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _iapProducts = response.productDetails;
    });

    var idx = 0;
    for (var prod in _iapProducts) {
      setState(() {
        _productIds[idx] = prod.id;
        _productDescriptions[idx] = prod.description;
        _productPrices[idx] = prod.price;
      });
    }
  }

  // getPast purchases
  // _iap.queryPastPurchases does not return consumed products
  // so it's only relevant for non-consumed products

  /// Purchase a product
  void _buyProduct(ProductDetails prod) {
    //ignore: omit_local_variable_types
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    // _iap.buyNonConsumable(purchaseParam: purchaseParam);
    /*, autoConsume: false block purchases again until marked as purchased */
    var isCons = _iap.buyConsumable(purchaseParam: purchaseParam);
    //print('_buyProduct');
    //print(isCons);
    _goForReward(prod.id);
  }

  Widget blueprintPlace() {
    return Ink(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (_blueprintImg == "")
              ? ExactAssetImage("assets/images/items/nothing.png")
              : ExactAssetImage("assets/images/blueprints/$_blueprintImg"),
          fit: BoxFit.contain,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await _clearPlacements();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlueprintSelectPage(),
            ),
          );
        },
        splashColor: Colors.brown.withOpacity(0.5),
      ),
    );
  }

  Widget materialPlace(int idx) {
    var mat0 = 0;
    for (var mat in _materialsId) {
      if (mat > 0) {
        mat0 = mat;
      }
    }

    return Ink(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (_materialsImg[idx] == "")
              ? ExactAssetImage("assets/images/items/nothing.png")
              : ExactAssetImage(
                  "assets/images/materials/${_materialsImg[idx]}"),
          fit: BoxFit.contain,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (_blueprintId == 0) {
            showDialog(
              context: context,
              builder: (context) => CustomDialog(
                title: 'Error',
                description: "Please select a blueprint first",
                buttonText: "Okay",
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialSelectPage(
                  blueprintId: _blueprintId, placement: idx, mat0: mat0),
            ),
          );
        },
        splashColor: Colors.brown.withOpacity(0.5),
      ),
    );
  }

  Widget itemLogo() {
    return Ink(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (_craftedItemImg == "")
              ? ExactAssetImage("assets/images/items/nothing.png")
              : ExactAssetImage("assets/images/items/$_craftedItemImg"),
          fit: BoxFit.contain,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await _craftItem();
        },
        splashColor: Colors.brown.withOpacity(0.5),
      ),
    );
  }

  void choiceAction(BuildContext context, PopupMenuChoice choice) async {
    if (choice == PopupMenuChoice.refreshForge) {
      await _clearPlacements();
    } else if (choice == PopupMenuChoice.showCoinSheet) {
      setState(() {
        _showCoinSheet = !_showCoinSheet;
      });
    }
  }

  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    int currentTabIndex = 2;

    /// Application top Bar
    final topBar = AppBar(
      leading: IconButton(
        color: GlobalConstants.appFg,
        icon: Icon(
          Icons.menu,
          // size: 32,
        ),
        onPressed: () => _scaffoldKey != null
            ? _scaffoldKey.currentState.openDrawer()
            : Navigator.of(context).pop(),
      ),
      elevation: 0.1,
      backgroundColor: Colors.transparent,
      title: Text(
        _isIapAvailable ? "Open" : "Closed",
        style: Style.topBar,
      ),
      actions: <Widget>[
        PopupMenuButton<PopupMenuChoice>(
          onSelected: (onSel) {
            choiceAction(context, onSel);
          },
          itemBuilder: (context) => <PopupMenuEntry<PopupMenuChoice>>[
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.refreshForge,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.autorenew,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Cleanup',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<PopupMenuChoice>(
              value: PopupMenuChoice.showCoinSheet,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.monetization_on,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Get more coins',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          color: GlobalConstants.appBg,
        ),
      ],
    );

    /// What happens when clicking the Bottom Navbar
    onTapped(int index) {
      setState(() {
        currentTabIndex = index;
      });
      if (index == 0) {
        //Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/inventory');
      } else if (index == 1) {
        //Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/research');
      }
    }

    final craftButton = RaisedButton(
      shape: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () async {
        await _craftItem();
      },
      padding:
          EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0),
      color: Colors.black,
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Icon(Icons.gavel, color: Color(0xffe6a04e)),
        Text(
          " Craft for ${GlobalConstants.craftingCost.toString()} Coins",
          style: TextStyle(
              color: Color(0xffe6a04e),
              fontSize: 18,
              fontFamily: 'Cormorant SC',
              fontWeight: FontWeight.bold),
        ),
      ]),
    );

    final watchAdButton = Padding(
      padding: EdgeInsets.all(0),
      child: RaisedButton(
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () {
          // Admob variant 1 :(
          _goForReward("AdReward");
          _admobAdvert.load();
        },
        padding:
            EdgeInsets.only(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0),
        color: Colors.black,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Icon(Icons.ondemand_video, color: Color(0xffe6a04e)),
          Text(
            " Watch ad",
            style: TextStyle(
                color: Color(0xffe6a04e),
                fontSize: 18,
                fontFamily: 'Cormorant SC',
                fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );

    Widget purchaseCoinsButton(int idx) {
      return Padding(
        padding: EdgeInsets.all(0),
        child: RaisedButton(
          shape: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            _buyProduct(_iapProducts[idx]);
          },
          padding:
              EdgeInsets.only(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0),
          color: Colors.black,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.shopping_cart, color: Color(0xffe6a04e)),
                Text(
                  " ${_productPrices[idx]}",
                  style: TextStyle(
                      color: Color(0xffe6a04e),
                      fontSize: 18,
                      fontFamily: 'Cormorant SC',
                      fontWeight: FontWeight.bold),
                ),
              ]),
        ),
      );
    }

    final coinSheet = Stack(
      children: <Widget>[
        Container(
          height: 170,
          padding: EdgeInsets.only(top: 0.0, left: 30.0, right: 30.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xcc222222)),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _showCoinSheet = !_showCoinSheet;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Watch an ad to gain a few coins.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          watchAdButton,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(width: 1),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _productDescriptions[0],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          purchaseCoinsButton(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: topBar,
      //extendBodyBehindAppBar: true,
      body: LoadingOverlay(
        isLoading: _isLoading,
        opacity: 0.5,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffe6a04e)),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/blacksmith_hammer.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _showCoinSheet ? coinSheet : SizedBox(height: 1),
                    Card(
                      color: Colors.transparent,
                      child: SizedBox(
                          child: blueprintPlace(), width: 120, height: 110),
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: Text(
                        (_blueprintName == "")
                            ? "Select Blueprint"
                            : _blueprintName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Cormorant SC',
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0))
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: SizedBox(
                          child: Icon(
                            Icons.add,
                            color: GlobalConstants.appFg,
                          ),
                          width: 30,
                          height: 30),
                    ),
                    Row(
                      children: <Widget>[
                        Card(
                          color: Colors.transparent,
                          child: SizedBox(
                              child: materialPlace(0), width: 120, height: 110),
                        ),
                        Card(
                          color: Colors.transparent,
                          child: SizedBox(
                              child: materialPlace(1), width: 120, height: 110),
                        ),
                        Card(
                          color: Colors.transparent,
                          child: SizedBox(
                              child: materialPlace(2), width: 120, height: 110),
                        ),
                      ],
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: Text(
                        'Materials',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Cormorant SC',
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0))
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Color.fromARGB(140, 0, 0, 0),
                      child: SizedBox(
                          child: Icon(
                            Icons.arrow_downward,
                            color: GlobalConstants.appFg,
                          ),
                          width: 30,
                          height: 30),
                    ),
                    Card(
                      color: Colors.transparent,
                      child:
                          SizedBox(child: itemLogo(), width: 120, height: 120),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[craftButton],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      drawer: DrawerPage(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTapped,
        currentIndex: currentTabIndex,
        backgroundColor: GlobalConstants.appBg,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted, color: Colors.white),
            title: Text(
              'Items',
              style: TextStyle(
                  color: (currentTabIndex == 0)
                      ? Color(0xfffeb53b)
                      : Colors.white),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_contacts, color: Colors.white),
            title: Text(
              'Research',
              style: TextStyle(
                  color: (currentTabIndex == 1)
                      ? Color(0xfffeb53b)
                      : Colors.white),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel, color: Colors.white),
            title: Text(
              'Forge',
              style: TextStyle(
                  color: (currentTabIndex == 2)
                      ? Color(0xfffeb53b)
                      : Colors.white),
            ),
          )
        ],
      ),
    );
  }

  void _getPlacements() async {
    var secureStorage = await _storage.readAll();
    setState(() {
      if (secureStorage.containsKey("forgeBlueprintId")) {
        _blueprintId = int.tryParse(secureStorage["forgeBlueprintId"]) ?? 0;
        _blueprintImg = secureStorage["forgeBlueprintImg"] ?? "nothing.png";
        _blueprintName = secureStorage["forgeBlueprintName"] ?? "Blueprint";
      }
      if (secureStorage.containsKey("forgeMaterial0Id")) {
        _materialsId[0] = int.tryParse(secureStorage["forgeMaterial0Id"]) ?? 0;
        _materialsImg[0] = secureStorage["forgeMaterial0Img"] ?? "nothing.png";
        _materialsName[0] = secureStorage["forgeMaterial0Name"] ?? "Material";
      }
      if (secureStorage.containsKey("forgeMaterial1Id")) {
        _materialsId[1] = int.tryParse(secureStorage["forgeMaterial1Id"]) ?? 0;
        _materialsImg[1] = secureStorage["forgeMaterial1Img"] ?? "nothing.png";
        _materialsName[1] = secureStorage["forgeMaterial1Name"] ?? "Material";
      }
      if (secureStorage.containsKey("forgeMaterial2Id")) {
        _materialsId[2] = int.tryParse(secureStorage["forgeMaterial2Id"]) ?? 0;
        _materialsImg[2] = secureStorage["forgeMaterial2Img"] ?? "nothing.png";
        _materialsName[2] = secureStorage["forgeMaterial2Name"] ?? "Material";
      }
    });
  }

  void _clearPlacements() async {
    await _storage.delete(key: 'forgeBlueprintId');
    await _storage.delete(key: 'forgeBlueprintImg');
    await _storage.delete(key: 'forgeBlueprintName');
    await _storage.delete(key: "forgeMaterial0Id");
    await _storage.delete(key: "forgeMaterial0Img");
    await _storage.delete(key: "forgeMaterial0Name");
    await _storage.delete(key: "forgeMaterial1Id");
    await _storage.delete(key: "forgeMaterial1Img");
    await _storage.delete(key: "forgeMaterial1Name");
    await _storage.delete(key: "forgeMaterial2Id");
    await _storage.delete(key: "forgeMaterial2Img");
    await _storage.delete(key: "forgeMaterial2Name");
    setState(() {
      _blueprintId = 0;
      _blueprintImg = "";
      _blueprintName = "";
      _materialsId = [0, 0, 0];
      _materialsImg = ["", "", ""];
      _materialsName = ["", "", ""];
    });
  }

  void _craftItem() async {
    if (_blueprintId <= 0) {
      await _clearPlacements();
      setState(() {
        _craftedItemImg = "";
        _craftedItemName = "";
      });
      return;
    }
    dynamic response;
    try {
      response = await _apiProvider.post(
          '/forge/${_blueprintId.toString()}/${_materialsId[0].toString()}/${_materialsId[1].toString()}/${_materialsId[2].toString()}',
          {});
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: '${err.response?.data['message']}',
          buttonText: "Okay",
        ),
      );
      return;
    }

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        if (response["items"][0]["nr"] > 0) {
          await _clearPlacements();
          setState(() {
            _craftedItemImg = response["items"][0]["img"];
            _craftedItemName = response["items"][0]["name"];
          });
        }
        if (response.containsKey("coins")) {
          _userdata.updateUserData(
            "",
            double.tryParse(response["coins"].toString()) ?? 0.0,
            0,
          );
        }
      }
    }
    return;
  }

  Future _serverReward(PurchaseDetails purchase) async {
    dynamic response;
    try {
      response = await _apiProvider.post(
        '/reward',
        {
          "token": _validationToken,
          "tid": _transactionId.toString(),
        },
      );
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: 'Ad reward failed to validate',
          buttonText: "Okay",
        ),
      );
      return;
    }

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _validationToken = "";
        _user.details.coins =
            double.tryParse(response["coins"].toString()) ?? 0.0;
        _transactionId = 0;

        setState(() {
          _isLoading = false;
        });

        if (purchase != null) {
          _iap.completePurchase(purchase);
        }

        _userdata.updateUserData(
          "",
          double.tryParse(response["coins"].toString()) ?? 0.0,
          0,
        );

        /// Retain the current total funds
        CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());

        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: AppLocalizations.of(context).translate('congrats'),
            description: "You gained ${response['amount']} coins, "
                "for a grand total of ${_user.details.coins.toString()} !",
            buttonText: "Okay",
          ),
        );
      }
    }
    return;
  }

  /// First step: get the tokens
  Future _goForReward(String rtype) async {
    dynamic response;
    try {
      response = await _apiProvider.get("/reward/$rtype");
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: 'Invalid ad server response. Please try again later.',
          buttonText: "Okay",
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _validationToken = response["token"] ?? "";
        _user.details.coins =
            double.tryParse(response["coins"].toString()) ?? 0.0;
        _transactionId = response["tid"] ?? 0;

        /// Retain the current total funds
        CustomInterceptors.setStoredCookies(
            GlobalConstants.apiHostUrl, _user.toMap());
        setState(() {
          _isLoading = true;
        });
      }
    }
    return;
  }

  /// Failure step: garbage collect
  Future _deleteReward() async {
    dynamic response;
    try {
      response = await _apiProvider
          .delete("/reward/$_validationToken/${_transactionId.toString()}", {});
    } on DioError catch (err) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Error',
          description: '${err.response?.data}',
          buttonText: "Okay",
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (response.containsKey("success")) {
      if (response["success"] == true) {
        _validationToken = "";
        _transactionId = 0;

        setState(() {
          _isLoading = false;
        });
      }
    }
    return;
  }

  void _getUserDetails() async {
    final user = await _apiProvider.getStoredUser();
    setState(() {
      _user = user;
    });
  }
}
