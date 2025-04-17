import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../models/geocam_model.dart';

class GeoCamProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _imagePath;
  bool _isLoading = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get imagePath => _imagePath;
  bool get hasLocation => _latitude != null && _longitude != null;
  bool get hasImage => _imagePath != null && _imagePath!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GeoCamProvider() {
    _loadSavedData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _loadSavedData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');
      final img = prefs.getString('imagePath');

      _latitude = lat;
      _longitude = lng;
      _imagePath = img;
    } catch (e) {
      _error = 'Error loading saved data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final hasPermission = await requestLocationPermission();
      
      if (!hasPermission) {
        _error = 'Location permission denied';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
    } catch (e) {
      _error = 'Error getting location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final hasPermission = await requestCameraPermission();
      
      if (!hasPermission) {
        _error = 'Camera permission denied';
        return;
      }

      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        _imagePath = photo.path;
      }
    } catch (e) {
      _error = 'Error taking photo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (_latitude == null || _longitude == null) {
        _error = 'No location data to save';
        return;
      }

      if (_imagePath == null || _imagePath!.isEmpty) {
        _error = 'No image to save';
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble('latitude', _latitude!);
      await prefs.setDouble('longitude', _longitude!);
      await prefs.setString('imagePath', _imagePath!);
    } catch (e) {
      _error = 'Error saving data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetData() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('latitude');
      await prefs.remove('longitude');
      await prefs.remove('imagePath');

      _latitude = null;
      _longitude = null;
      _imagePath = null;
    } catch (e) {
      _error = 'Error resetting data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  GeoCamModel get currentData {
    return GeoCamModel(
      latitude: _latitude,
      longitude: _longitude,
      imagePath: _imagePath,
    );
  }

}