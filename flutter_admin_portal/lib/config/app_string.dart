class AppString {
  AppString._();

  static const String dashboardTitle = 'Smart TV Central Controller';
  static const String dashboardSubtitle = 'Multi-TV Realtime Gate Check-In & Welcome Display (webOS 22)';

  static const String tvMonitorTitle = 'Connected Displays (3x webOS 22 TVs)';
  static const String visitorQueueTitle = 'Gate Visitor Activity & Welcome Queue';
  static const String settingsTitle = 'Display & Automation Rules';

  static const String autoApproveLabel = 'Auto-Approve Visitors';
  static const String autoApproveDesc = 'Broadcast photo to all 3 TVs immediately upon gate QR check-in';

  static const String priorityDurationLabel = 'Priority Takeover Duration';
  static const String priorityDurationVal = '5 Minutes (300 seconds)';

  static const String broadcastBtn = 'Broadcast Alert';
  static const String forcePlayBtn = 'Force Play on 3 TVs (5 Min)';
  static const String approveBtn = 'Approve';
  static const String rejectBtn = 'Reject';

  static const String statusOnline = 'ONLINE';
  static const String statusOffline = 'OFFLINE';

  static const String emptyVisitors = 'No visitors have checked in yet.';
  static const String errorLoading = 'Failed to synchronize with server. Retrying...';
}
