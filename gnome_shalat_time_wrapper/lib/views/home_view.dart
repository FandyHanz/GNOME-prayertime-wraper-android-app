import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../controllers/prayer_controller.dart';
import 'settings_view.dart';

class HomeView extends StatelessWidget {
  final PrayerController controller;
  const HomeView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final active = controller.prayers.isNotEmpty ? controller.prayers[controller.nextPrayerIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F29), // Palette GNOME Dark
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F29),
        elevation: 0,
        title: const Text('Prayer Times', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsView(controller: controller)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Pill capsule atas
            if (active != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF383A4C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${active.name} - ${timeFormat.format(active.time)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ),
            const SizedBox(height: 24),

            // Card list utama
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF262837),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.prayers.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.prayers[index];
                    final isNext = index == controller.nextPrayerIndex;

                    return ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/${item.id}.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isNext ? Colors.amber : Colors.white70,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                          color: isNext ? Colors.amber : Colors.white,
                        ),
                      ),
                      trailing: Text(
                        timeFormat.format(item.time),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                          color: isNext ? Colors.amber : Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}