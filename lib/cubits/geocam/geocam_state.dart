import 'package:equatable/equatable.dart';
import '../../models/geocam_model.dart';

class GeoCamState extends Equatable {
  final double? latitude;
  final double? longitude;
  final String? imagePath;
  final bool isLoading;
  final String? error;

  const GeoCamState({
    this.latitude,
    this.longitude,
    this.imagePath,
    this.isLoading = false,
    this.error,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  GeoCamModel get currentData => GeoCamModel(
    latitude: latitude,
    longitude: longitude,
    imagePath: imagePath,
  );

  GeoCamState copyWith({
    double? latitude,
    double? longitude,
    String? imagePath,
    bool? isLoading,
    String? error,
  }) {
    return GeoCamState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  GeoCamState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [latitude, longitude, imagePath, isLoading, error];
}