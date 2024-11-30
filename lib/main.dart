import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:currensee_convertor_app/Auth.dart';
import 'package:currensee_convertor_app/CurrencyConvertor.dart';
import 'package:currensee_convertor_app/CurrencyData.dart';
import 'package:currensee_convertor_app/FAqs.dart';
import 'package:currensee_convertor_app/charts.dart';
import 'package:currensee_convertor_app/conversion_history_screen.dart';
import 'package:currensee_convertor_app/example.dart';
import 'package:currensee_convertor_app/feedback.dart';
import 'package:currensee_convertor_app/home.dart';
import 'package:currensee_convertor_app/login.dart';
import 'package:currensee_convertor_app/new_trend.dart';
import 'package:currensee_convertor_app/rateAlter.dart';
import 'package:currensee_convertor_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'basicchanel',
          channelName: 'basic notification',
          channelDescription: 'basic description add')
    ],
    debug: true,
  );
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyCYaHkCrgxkN6D6DvgoTBWmcZgmrHa596Y",
    authDomain: "ecommerceflutter-431f9.firebaseapp.com",
    projectId: "ecommerceflutter-431f9",
    storageBucket: "ecommerceflutter-431f9.appspot.com",
    messagingSenderId: "1048901164048",
    appId: "1:1048901164048:web:8b5259e09a66c5267d3e95",
    databaseURL: "https://ecommerceflutter-431f9-default-rtdb.firebaseio.com",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        iconTheme: IconThemeData(
          color: AppColors.white, // Set global icon color to white
        ),
      ),
      debugShowCheckedModeBanner: false,
      // theme: AppColors.backgroundColor,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => Home(),
        '/history': (context) => ConversionHistoryScreen(),
        '/setrate': (context) => SetCurrency(),
        // '/currency': (context) => CurrencyData(),
        // '/settings': (context) => SettingsScreen(),
        '/news': (context) => NewsTrendsScreen(),
        '/feedback': (context) => FeedbackPage(),
        '/faqs': (context) => HelpAndSupportPage(),
      },

      // home: CurrencyConverterApp(),
      // home: CurrencyConverter(),
      // home: AuthPage(),
      // home: ConversionHistoryScreen(),
      // home: MarketNewsPage(),
      // home: FeedbackPage(),
      // home: RateAlertPage(),
      // home: HelpAndSupportPage(),
    );
  }
}
