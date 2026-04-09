class PartnerModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String photoUrl;
  final String assignedOrdersCount;
  final bool isAvailable;

  PartnerModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.photoUrl,
    required this.assignedOrdersCount,
    required this.isAvailable,
  });

  factory PartnerModel.fromMap(Map<String, dynamic> map, String id) {
    return PartnerModel(
      id: id,
      name: map['name']?.toString() ?? 'Unknown Partner',
      phoneNumber: map['phoneNumber']?.toString() ?? 'N/A',
      photoUrl: map['photoUrl']?.toString() ?? '',
      assignedOrdersCount: map['assignedOrdersCount']?.toString() ?? '0',
      isAvailable: map['isAvailable'] == true,
    );
  }
}