import 'dart:io';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  List<CameraDescription> get cameras => _cameras;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      // Request camera permissions
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        throw Exception('Camera permission not granted');
      }

      // Request location permissions
      final locationStatus = await Permission.location.request();
      if (locationStatus != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize camera controller with back camera
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false, // Disable audio for photos
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<CameraImage?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _controller!.takePicture();
      return null; // Return null as we'll process the file directly
    } catch (e) {
      rethrow;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> capturePhotoWithLocation() async {
    try {
      // Get current location
      final Position? position = await getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get current location');
      }

      // Take photo
      final XFile photo = await _controller!.takePicture();
      
      // Get address from coordinates
      final String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'photoPath': photo.path,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
        'address': address,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
      };
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }

  void switchCamera() async {
    if (_cameras.length < 2) return;
    
    final currentIndex = _cameras.indexOf(_controller!.description);
    final newIndex = (currentIndex + 1) % _cameras.length;
    
    await _controller!.dispose();
    _controller = CameraController(
      _cameras[newIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    await _controller!.initialize();
  }
} 