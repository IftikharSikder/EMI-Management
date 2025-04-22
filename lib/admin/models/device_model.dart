class Device {
  final String id;
  final String deviceName;
  final int availableQuantity;
  final double unitPrice;
  final String imageUrl;
  final String dId; // Added this field

  Device({
    required this.id,
    required this.deviceName,
    required this.availableQuantity,
    required this.unitPrice,
    required this.imageUrl,
    this.dId = '', // Default empty string
  });

  factory Device.fromFirestore(Map<String, dynamic> data, String docId) {
    return Device(
      id: docId,
      deviceName: data['device_name'] ?? '',
      availableQuantity: data['available_quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      imageUrl: data['img_url'] ?? '',
      dId: data['d_id'] ?? docId, // Use document ID as fallback
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'device_name': deviceName,
      'available_quantity': availableQuantity,
      'unit_price': unitPrice,
      'img_url': imageUrl,
      'd_id': dId.isNotEmpty ? dId : id, // Use d_id if available, otherwise use id
    };
  }
}
