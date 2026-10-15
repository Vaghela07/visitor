class TVDeviceModel {
  final String id;
  final String name;
  final String location;
  final String status; // 'online' | 'offline'
  final String currentMode; // 'priority_welcome' | 'ambient'
  final DateTime? lastSeen;

  TVDeviceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.currentMode,
    this.lastSeen,
  });

  factory TVDeviceModel.fromJson(Map<String, dynamic> json) {
    return TVDeviceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Smart TV',
      location: json['location']?.toString() ?? 'Residence Area',
      status: json['status']?.toString() ?? 'offline',
      currentMode: json['currentMode']?.toString() ?? 'ambient',
      lastSeen: json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen'].toString()) : null,
    );
  }

  bool get isOnline => status == 'online';
  bool get isPriorityMode => currentMode == 'priority_welcome';
}
