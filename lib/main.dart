// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/plant_service.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart'; // 👈 이 줄을 추가하세요.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initializeApp에 options를 추가합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 👈 이 부분을 추가하세요.
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Plant Pot',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}