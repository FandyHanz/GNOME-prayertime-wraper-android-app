import 'package:flutter/material.dart';
import '../controllers/prayer_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  final PrayerController controller;
  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F29),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1E1F29),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Group Location Calculations (GPS & Custom Lat/Lng)
          const Text(
            'Location Calculations',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262837),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.amber),
                  title: const Text('Locate with GPS'),
                  subtitle: const Text('Update Lat/Long automatically'),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Getting GPS location...')),
                    );
                    final success =
                        await widget.controller.updateLocationFromGPS();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Location updated!'
                                : 'Failed to get GPS location',
                          ),
                        ),
                      );
                      setState(() {});
                    }
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: const Text('Latitude'),
                  subtitle: Text(settings.latitude.toStringAsFixed(4)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() => settings.latitude -= 0.001);
                          widget.controller.refreshSchedule();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => settings.latitude += 0.001);
                          widget.controller.refreshSchedule();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: const Text('Longitude'),
                  subtitle: Text(settings.longitude.toStringAsFixed(4)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() => settings.longitude -= 0.001);
                          widget.controller.refreshSchedule();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => settings.longitude += 0.001);
                          widget.controller.refreshSchedule();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Group Calculation Methods & Shadow Method
          const Text(
            'Calculation Methods',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262837),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Preset Method'),
                  trailing: DropdownButton<String>(
                    dropdownColor: const Color(0xFF262837),
                    value: settings.calcMethod,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'custom', child: Text('Custom')),
                      DropdownMenuItem(
                        value: 'egypt',
                        child: Text('Egyptian General Survey'),
                      ),
                      DropdownMenuItem(
                        value: 'mwl',
                        child: Text('Muslim World League'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => settings.calcMethod = val);
                      widget.controller.refreshSchedule();
                    },
                  ),
                ),
                if (settings.calcMethod == 'custom') ...[
                  const Divider(color: Colors.white12, height: 1),
                  ListTile(
                    title: const Text('Fajr Angle'),
                    subtitle: Text('${settings.fajrAngle.toStringAsFixed(1)}°'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() => settings.fajrAngle -= 0.5);
                            widget.controller.refreshSchedule();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() => settings.fajrAngle += 0.5);
                            widget.controller.refreshSchedule();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  ListTile(
                    title: const Text('Isha Angle'),
                    subtitle: Text('${settings.ishaAngle.toStringAsFixed(1)}°'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() => settings.ishaAngle -= 0.5);
                            widget.controller.refreshSchedule();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() => settings.ishaAngle += 0.5);
                            widget.controller.refreshSchedule();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: const Text('Asr Shadow Method'),
                  trailing: DropdownButton<String>(
                    dropdownColor: const Color(0xFF262837),
                    value: settings.asrMethod,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'standard',
                        child: Text('Hanbali, Maliki, Shafi'),
                      ),
                      DropdownMenuItem(value: 'hanafi', child: Text('Hanafi')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => settings.asrMethod = val);
                      widget.controller.refreshSchedule();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Group Notifications (Ongoing & Alert Banner)
          const Text(
            'Notifications',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262837),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Ongoing Status Notification'),
                  subtitle: const Text(
                    'Show next prayer info pinned in notification bar',
                  ),
                  value: settings.isPersistent,
                  onChanged: (val) {
                    setState(() => settings.isPersistent = val);
                    widget.controller.refreshSchedule();
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  title: const Text('Prayer Time Alerts'),
                  subtitle: const Text(
                    'Swipeable pop-up banner when time arrives',
                  ),
                  value: settings.isNotify,
                  onChanged: (val) {
                    setState(() => settings.isNotify = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Group About Us
          const Text(
            'About Us',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262837),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/icons/logo.jpeg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.info_outline, color: Colors.amber),
                    ),
                  ),
                  title: const Text('Prayer Times Wrapper', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Rebuilt by Fandy Hanz'),
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: const Text('License'),
                  subtitle: const Text('GPL 3.0 / MIT License (PrayTimes Algorithm)'),
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: const Text('Original GitHub Repository'),
                  subtitle: const Text(
                    'https://github.com/Mocab/Prayer-times-gnome-extension',
                    style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 20, color: Colors.white70),
                  onTap: () async {
                    final uri = Uri.parse('https://github.com/Mocab/Prayer-times-gnome-extension');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}