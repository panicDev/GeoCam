class GeoCamModel {
  final double? latitude;
  final double? longitude;
  final String? imagePath;

  GeoCamModel({
    this.latitude,
    this.longitude,
    this.imagePath,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  factory GeoCamModel.fromJson(Map<String, dynamic> json) {
    return GeoCamModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
    };
  }
}