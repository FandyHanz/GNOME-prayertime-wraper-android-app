import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/prayer_item.dart';
import '../models/app_settings.dart';
import 'notification_service.dart';
import 'package:geolocator/geolocator.dart';

class PrayerController extends ChangeNotifier {
  final AppSettings settings = AppSettings();
  List<PrayerItem> prayers = [];
  int nextPrayerIndex = 0;
  Timer? _ticker;

  PrayerController() {
    refreshSchedule();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  void refreshSchedule() {
    final now = DateTime.now();
    prayers = _calculatePrayersForDate(now);
    _resolveNextPrayer(now);
    notifyListeners();

    _tick();
  }

  void _resolveNextPrayer(DateTime now) {
    nextPrayerIndex = prayers.indexWhere((p) => p.time.isAfter(now));
    if (nextPrayerIndex == -1) {
      // Lewat isha, jadwal berikutnya fajr besok
      final tomorrowPrayers = _calculatePrayersForDate(
        now.add(const Duration(days: 1)),
      );
      prayers = tomorrowPrayers;
      nextPrayerIndex = 0;
    }
  }

  void _tick() {
  final now = DateTime.now();
  _resolveNextPrayer(now);
  notifyListeners();

  if (prayers.isEmpty) return;

  final target = prayers[nextPrayerIndex];
  final diff = target.time.difference(now);
  final formatTime = DateFormat('hh:mm a').format(target.time);

  if (settings.isPersistent) {
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    final timeRemainingStr = hours > 0 
        ? '$hours jam $mins mnt lagi' 
        : '$mins mnt lagi';

    print("DEBUG: Nampilin notif -> ${target.name} ($formatTime)"); // <-- Tambah print ini

    NotificationService.showPersistentNotification(
      title: 'Next: ${target.name} ($formatTime)',
      body: 'Masuk waktu dalam $timeRemainingStr',
    );
  } else {
    NotificationService.cancelPersistent();
  }
}

  // Engine praytimes.org porting dari calc-prayer-times.js
  List<PrayerItem> _calculatePrayersForDate(DateTime date) {
    final jd =
        _julianDate(date.year, date.month, date.day) -
        730120.5 -
        settings.longitude / 360.0;
    final noonSun = _getSunPos(jd);

    double fajrAngle = settings.fajrAngle;
    double ishaAngle = settings.ishaAngle;
    if (settings.calcMethod == 'mwl') {
      fajrAngle = 18.0;
      ishaAngle = 17.0;
    } else if (settings.calcMethod == 'egypt') {
      fajrAngle = 19.5;
      ishaAngle = 17.5;
    }

    final sunrise = _sunTime(noonSun, 0.833, jd, -1);
    final sunset = _sunTime(noonSun, 0.833, jd, 1);
    final dhuhrHours = _mod(12 - noonSun['timeEq']!, 24);

    // Asr shadow formula
    final shadowFactor = settings.asrMethod == 'hanafi' ? 2 : 1;
    final asrAngle = -_arccot(
      shadowFactor + _tan((settings.latitude - noonSun['sunDecl']!).abs()),
    );
    final asrHours = _sunTime(noonSun, asrAngle, jd, 1);

    final fajrHours = _sunTime(noonSun, fajrAngle, jd, -1);
    final maghribHours = sunset + 0.017;
    final ishaHours = _sunTime(noonSun, ishaAngle, jd, 1);

    DateTime toDate(double fractionalHours) {
      final utcMid = DateTime.utc(date.year, date.month, date.day);
      final offsetHours = settings.longitude / 15.0;
      final minutes = ((fractionalHours - offsetHours) * 60).round();
      return utcMid.add(Duration(minutes: minutes)).toLocal();
    }

    return [
      PrayerItem(id: 'fajr', name: 'Fajr', time: toDate(fajrHours)),
      PrayerItem(
        id: 'dhuhr',
        name: date.weekday == DateTime.friday ? 'Jumaah' : 'Dhuhr',
        time: toDate(dhuhrHours),
      ),
      PrayerItem(id: 'asr', name: 'Asr', time: toDate(asrHours)),
      PrayerItem(id: 'maghrib', name: 'Maghrib', time: toDate(maghribHours)),
      PrayerItem(id: 'isha', name: 'Isha', time: toDate(ishaHours)),
    ];
  }

  Future<bool> updateLocationFromGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    settings.latitude = pos.latitude;
    settings.longitude = pos.longitude;
    refreshSchedule();
    return true;
  }

  // Math helpers
  double _dtr(double d) => d * math.pi / 180.0;
  double _rtd(double r) => r * 180.0 / math.pi;
  double _sin(double d) => math.sin(_dtr(d));
  double _cos(double d) => math.cos(_dtr(d));
  double _tan(double d) => math.tan(_dtr(d));
  double _arccot(double x) => _rtd(math.atan(1 / x));
  double _mod(double a, double b) => ((a % b) + b) % b;

  double _julianDate(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  Map<String, double> _getSunPos(double jd, [double approx = 12.0]) {
    final d = jd + approx / 24.0;
    final g = _mod(357.529 + 0.98560028 * d, 360);
    final q = _mod(280.459 + 0.98564736 * d, 360);
    final l = _mod(q + 1.915 * _sin(g) + 0.02 * _sin(2 * g), 360);
    final e = 23.439 - 0.00000036 * d;
    final sinL = _sin(l);
    final sunDecl = _rtd(math.asin(_sin(e) * sinL));
    final timeEq =
        q / 15.0 - _mod(_rtd(math.atan2(_cos(e) * sinL, _cos(l))) / 15.0, 24);
    return {'sunDecl': sunDecl, 'timeEq': timeEq};
  }

  double _sunTime(
    Map<String, double> noonSun,
    double angle,
    double jd,
    double dir,
  ) {
    final mid = _mod(12 - noonSun['timeEq']!, 24);
    final num =
        -_sin(angle) - _sin(settings.latitude) * _sin(noonSun['sunDecl']!);
    final den = _cos(settings.latitude) * _cos(noonSun['sunDecl']!);
    final val = (num / den).clamp(-1.0, 1.0);
    final diff = _rtd(math.acos(val)) / 15.0;
    return mid + diff * dir;
  }

  double getQiblaBearing() {
    const makkahLat = 21.4225;
    const makkahLng = 39.8262;

    final phi1 = _dtr(settings.latitude);
    final phi2 = _dtr(makkahLat);
    final deltaLambda = _dtr(makkahLng - settings.longitude);

    final y = math.sin(deltaLambda);
    final x =
        math.cos(phi1) * math.tan(phi2) -
        math.sin(phi1) * math.cos(deltaLambda);

    final qiblaRad = math.atan2(y, x);
    return (_rtd(qiblaRad) + 360) % 360;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
