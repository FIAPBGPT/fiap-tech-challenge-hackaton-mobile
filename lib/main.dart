import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/firebase_options.dart';
import 'package:fiap_farms_app/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await runZonedGuarded(
    () async {
  WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(child: MyApp()),
  );
    },
    (error, stackTrace) async {
      print(error);
    },
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIAP Farms',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashPage(), 
    );
  }
}
