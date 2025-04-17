import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/geocam_model.dart';
import 'geocam_state.dart';

class GeoCamCubit extends Cubit<GeoCamState> {
  final ImagePicker _picker = ImagePicker();

  GeoCamCubit() : super(const GeoCamState()) {
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');
      final img = prefs.getString('imagePath');

      emit(state.copyWith(
        latitude: lat,
        longitude: lng,
        imagePath: img,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error loading saved data: $e',
        isLoading: false,
      ));
    }
  }

  void clearError() {
    emit(state.clearError());
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> getCurrentLocation() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final hasPermission = await requestLocationPermission();
      
      if (!hasPermission) {
        emit(state.copyWith(
          error: 'Location permission denied',
          isLoading: false,
        ));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      emit(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error getting location: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> takePhoto() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final hasPermission = await requestCameraPermission();
      
      if (!hasPermission) {
        emit(state.copyWith(
          error: 'Camera permission denied',
          isLoading: false,
        ));
        return;
      }

      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        emit(state.copyWith(
          imagePath: photo.path,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Error taking photo: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> saveData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      if (state.latitude == null || state.longitude == null) {
        emit(state.copyWith(
          error: 'No location data to save',
          isLoading: false,
        ));
        return;
      }

      if (state.imagePath == null || state.imagePath!.isEmpty) {
        emit(state.copyWith(
          error: 'No image to save',
          isLoading: false,
        ));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble('latitude', state.latitude!);
      await prefs.setDouble('longitude', state.longitude!);
      await prefs.setString('imagePath', state.imagePath!);
      
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error saving data: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> resetData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('latitude');
      await prefs.remove('longitude');
      await prefs.remove('imagePath');

      emit(state.copyWith(
        latitude: null,
        longitude: null,
        imagePath: null,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error resetting data: $e',
        isLoading: false,
      ));
    }
  }
}