import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:mobile_avicast/services/network_discovery_service.dart';

class NetworkProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isLocalNetworkAvailable = false;
  String? _currentNetworkName;
  String? _localServerUrl;
  bool _isDiscovering = false;
  List<String> _availableServers = [];
  String? _error;

  // Getters
  bool get isConnected => _isConnected;
  bool get isLocalNetworkAvailable => _isLocalNetworkAvailable;
  String? get currentNetworkName => _currentNetworkName;
  String? get localServerUrl => _localServerUrl;
  bool get isDiscovering => _isDiscovering;
  List<String> get availableServers => _availableServers;
  String? get error => _error;

  final NetworkInfo _networkInfo = NetworkInfo();
  final NetworkDiscoveryService _discoveryService = NetworkDiscoveryService();
  final Connectivity _connectivity = Connectivity();

  NetworkProvider() {
    _initializeNetworkMonitoring();
  }

  Future<void> _initializeNetworkMonitoring() async {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    
    // Check initial connectivity
    await _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(connectivityResult);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    bool wasConnected = _isConnected;
    
    _isConnected = result != ConnectivityResult.none;
    
    if (_isConnected && !wasConnected) {
      // Just connected, check for local network
      await _checkLocalNetwork();
    } else if (!_isConnected && wasConnected) {
      // Just disconnected
      _isLocalNetworkAvailable = false;
      _localServerUrl = null;
      _availableServers.clear();
    }
    
    notifyListeners();
  }

  Future<void> _checkLocalNetwork() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      _currentNetworkName = wifiName;
      
      // Check if we're on a known local network
      if (wifiName != null && _isKnownLocalNetwork(wifiName)) {
        await _discoverLocalServers();
      }
    } catch (e) {
      debugPrint('Error checking local network: $e');
    }
  }

  bool _isKnownLocalNetwork(String networkName) {
    // Add your known local network names here
    final knownNetworks = [
      'Avicast_Local',
      'Avicast_Office',
      'Avicast_Field',
      // Add more as needed
    ];
    
    return knownNetworks.any((network) => 
        networkName.toLowerCase().contains(network.toLowerCase()));
  }

  Future<void> _discoverLocalServers() async {
    if (_isDiscovering) return;
    
    _setDiscovering(true);
    _clearError();
    
    try {
      final servers = await _discoveryService.discoverLocalServers();
      _availableServers = servers;
      
      if (servers.isNotEmpty) {
        _isLocalNetworkAvailable = true;
        _localServerUrl = servers.first; // Use first available server
      } else {
        _isLocalNetworkAvailable = false;
        _localServerUrl = null;
      }
    } catch (e) {
      _setError('Failed to discover local servers: ${e.toString()}');
      _isLocalNetworkAvailable = false;
      _localServerUrl = null;
    } finally {
      _setDiscovering(false);
    }
  }

  Future<void> manualServerDiscovery() async {
    await _discoverLocalServers();
  }

  Future<void> setLocalServerUrl(String url) async {
    _localServerUrl = url;
    _isLocalNetworkAvailable = true;
    notifyListeners();
  }

  Future<bool> testServerConnection(String url) async {
    try {
      final isReachable = await _discoveryService.testServerConnection(url);
      if (isReachable) {
        _localServerUrl = url;
        _isLocalNetworkAvailable = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Connection test failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> refreshNetworkStatus() async {
    await _checkConnectivity();
    if (_isConnected) {
      await _checkLocalNetwork();
    }
  }

  void _setDiscovering(bool discovering) {
    _isDiscovering = discovering;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _connectivity.onConnectivityChanged.drain();
    super.dispose();
  }
} 