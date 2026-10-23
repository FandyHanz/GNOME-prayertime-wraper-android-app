import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../controllers/prayer_controller.dart';

class QiblaView extends StatelessWidget {
  final PrayerController controller;
  const QiblaView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final qiblaBearing = controller.getQiblaBearing();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F29),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.heading == null) {
            return const Center(
              child: Text(
                'Sensor kompas tidak terdeteksi atau butuh kalibrasi',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final heading = snapshot.data!.heading!;
          // Putaran jarum kompas ke arah Ka'bah
          final qiblaOffset = (qiblaBearing - heading) * (math.pi / 180);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Arah Kiblat: ${qiblaBearing.toStringAsFixed(1)}°',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  'Heading: ${heading.toStringAsFixed(1)}°',
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran Piringan Kompas
                    Transform.rotate(
                      angle: -heading * (math.pi / 180),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF262837),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('U', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Jarum Penunjuk Kiblat
                    Transform.rotate(
                      angle: qiblaOffset,
                      child: const Icon(
                        Icons.navigation,
                        size: 90,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}