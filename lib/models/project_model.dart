class Project {
  final String id;
  final String userId;
  final String projectNumber; // ARP001, ARP002, etc.
  final String place;
  final String nearbyTown;
  final String taluk;
  final String district;
  final String mapLocation;
  final DateTime dateOfVisit;
  final String status;
  
  // Feature selection
  final String? selectedFeature; // lingam, avudai, or nandhi
  
  // Lingam specific
  final String? lingamType; // old or new
  final String? lingamDimension; // predefined or custom
  final double? lingamAmount;
  
  // Local contact
  final String localContactName;
  final String localContactPhone;
  
  // Images (URLs will be stored here after upload)
  final List<String> imageUrls;
  
  final double estimatedAmount;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.userId,
    required this.projectNumber,
    required this.place,
    required this.nearbyTown,
    required this.taluk,
    required this.district,
    required this.mapLocation,
    required this.dateOfVisit,
    required this.status,
    this.selectedFeature,
    this.lingamType,
    this.lingamDimension,
    this.lingamAmount,
    required this.localContactName,
    required this.localContactPhone,
    required this.imageUrls,
    required this.estimatedAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectNumber': projectNumber,
      'place': place,
      'nearbyTown': nearbyTown,
      'taluk': taluk,
      'district': district,
      'mapLocation': mapLocation,
      'dateOfVisit': dateOfVisit,
      'status': status,
      'selectedFeature': selectedFeature,
      'lingamType': lingamType,
      'lingamDimension': lingamDimension,
      'lingamAmount': lingamAmount,
      'localContactName': localContactName,
      'localContactPhone': localContactPhone,
      'imageUrls': imageUrls,
      'estimatedAmount': estimatedAmount,
      'createdAt': createdAt,
    };
  }
}