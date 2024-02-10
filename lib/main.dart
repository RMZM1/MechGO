import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/global/keys.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/infoHandler/app_info.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.restartApp();
  }
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  late StreamSubscription _sub;

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: ChangeNotifierProvider(
        create: (BuildContext context) {
          return AppInformation();
        },
        child: MaterialApp(
          title: 'Mechanic On The Go',
          theme: ThemeData(
            primarySwatch: themeColor,
            primaryColor: Colors.white70,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }

  Future<void> initUniLinks() async {
    try {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          if (uri.scheme == 'mechgo') {
            handleDeepLinkParameters(context, uri.queryParameters);
          }
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Deep Link Error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);    }
  }

  void handleDeepLinkParameters(BuildContext context, Map<String, String> queryParameters,) {
    var stripeOnBoardingComplete = queryParameters['stripeOnBoardingComplete'];
    // var message = queryParameters['message'];
    if (stripeOnBoardingComplete == 'true') {
      db.ref().child("users").child(currentFireBaseUser!.uid).update({
        "stripeOnBoardingComplete":true,
      }).then((value){
        Fluttertoast.showToast(
            msg: "Status Updated",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        restartApp();
      });
    } else {
      Fluttertoast.showToast(
          msg: "Could not retrieve Stripe Account",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
