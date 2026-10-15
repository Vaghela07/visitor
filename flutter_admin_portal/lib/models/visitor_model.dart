class VisitorModel {
  final String id;
  final String name;
  final String phone;
  final List<String> photos;
  final String status; // 'approved' | 'pending'
  final DateTime timestamp;

  VisitorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.photos,
    required this.status,
    required this.timestamp,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Visitor',
      phone: json['phone']?.toString() ?? '',
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status']?.toString() ?? 'pending',
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'photos': photos,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
  };

  bool get isApproved => status == 'approved';
}
