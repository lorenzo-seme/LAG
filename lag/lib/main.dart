import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/splash.dart';
import 'package:provider/provider.dart';

void main() { 
  runApp(const MyApp()); 
}         

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (context) => HomeProvider(), 
          builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const Splash()
          )
    );
  }
}