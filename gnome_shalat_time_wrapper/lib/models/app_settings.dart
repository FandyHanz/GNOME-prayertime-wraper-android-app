class AppSettings {
  double latitude;
  double longitude;
  String calcMethod;
  double fajrAngle;
  double ishaAngle;
  String asrMethod;
  String highLatAdjustment;
  bool isNotify;
  int reminder;
  bool isPersistent;


  AppSettings({
    this.latitude = -7.9839, // Malang / default
    this.longitude = 112.6214,
    this.calcMethod = 'custom',
    this.fajrAngle = 20.0,
    this.ishaAngle = 18.0,
    this.asrMethod = 'standard',
    this.highLatAdjustment = 'night-middle',
    this.isNotify = true,
    this.isPersistent = true,
    this.reminder = 0,
  });
}
