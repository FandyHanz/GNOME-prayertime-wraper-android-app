import 'package:flutter/material.dart';
import 'controllers/notification_service.dart';
import 'controllers/prayer_controller.dart';
import 'views/home_view.dart';
import 'views/qibla_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PrayerController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: MainScreen(controller: controller),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final PrayerController controller;
  const MainScreen({super.key, required this.controller});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeView(controller: widget.controller),
      QiblaView(controller: widget.controller),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E1F29),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white38,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Prayer Times'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
        ],
      ),
    );
  }
}