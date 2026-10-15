class AppConsts {
  AppConsts._();

  static const String appTitle = 'Smart TV Visitor Sync Hub';
  static const String baseUrl = 'http://localhost:5000';
  static const Duration requestTimeout = Duration(seconds: 10);

  // Slideshow Timers
  static const int priorityWelcomeDurationSeconds = 300; // 5 minutes
  static const int ambientSlideIntervalSeconds = 8;

  // Endpoints
  static const String epVisitors = '/api/admin/visitors';
  static const String epApproveVisitor = '/api/admin/approve';
  static const String epRejectVisitor = '/api/admin/reject';
  static const String epTVStatus = '/api/tv/status';
  static const String epBroadcast = '/api/admin/broadcast-message';
  static const String epSettings = '/api/admin/settings';
  static const String epAmbientPhotos = '/api/photos/ambient';
}
