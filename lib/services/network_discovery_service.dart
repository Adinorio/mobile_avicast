import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

class NetworkDiscoveryService {
  static const int _discoveryPort = 8000; // Default Django port
  static const Duration _timeout = Duration(seconds: 2);
  static const List<String> _commonPaths = [
    '/',
    '/admin/',
    '/api/',
    '/health/',
  ];

  final NetworkInfo _networkInfo = NetworkInfo();

  /// Discovers local servers on the current WiFi network
  Future<List<String>> discoverLocalServers() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      if (wifiIP == null) return [];

      final baseIP = _getBaseIP(wifiIP);
      final servers = <String>[];

      // Scan common IP ranges
      for (int i = 1; i <= 254; i++) {
        final ip = '$baseIP.$i';
        final serverUrl = await _testServerConnection(ip);
        if (serverUrl != null) {
          servers.add(serverUrl);
        }
      }

      return servers;
    } catch (e) {
      print('Error discovering servers: $e');
      return [];
    }
  }

  /// Tests if a specific IP address is running a Django server
  Future<String?> _testServerConnection(String ip) async {
    for (final path in _commonPaths) {
      try {
        final url = 'http://$ip:$_discoveryPort$path';
        final response = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(_timeout);

        if (response.statusCode == 200 || response.statusCode == 403) {
          // 403 is common for Django admin without proper auth
          // 200 means the server is reachable
          return 'http://$ip:$_discoveryPort';
        }
      } catch (e) {
        // Connection failed, try next path
        continue;
      }
    }
    return null;
  }

  /// Tests connection to a specific server URL
  Future<bool> testServerConnection(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$url/'),
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 403;
    } catch (e) {
      return false;
    }
  }

  /// Gets the base IP address (e.g., "192.168.1" from "192.168.1.100")
  String _getBaseIP(String ip) {
    final parts = ip.split('.');
    if (parts.length >= 3) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return ip;
  }

  /// Scans for servers on specific ports
  Future<List<String>> scanPorts(String baseIP, List<int> ports) async {
    final servers = <String>[];
    
    for (final port in ports) {
      for (int i = 1; i <= 254; i++) {
        final ip = '$baseIP.$i';
        final url = 'http://$ip:$port';
        
        if (await testServerConnection(url)) {
          servers.add(url);
        }
      }
    }
    
    return servers;
  }

  /// Discovers servers using mDNS/Bonjour (if available)
  Future<List<String>> discoverUsingMDNS() async {
    // This would require additional packages like mdns_plugin
    // For now, return empty list
    return [];
  }

  /// Manually add a server URL
  Future<bool> addServerManually(String url) async {
    return await testServerConnection(url);
  }

  /// Get current network information
  Future<Map<String, String?>> getNetworkInfo() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      
      return {
        'name': wifiName,
        'ip': wifiIP,
        'bssid': wifiBSSID,
      };
    } catch (e) {
      return {};
    }
  }

  /// Check if we're on a known network
  Future<bool> isKnownNetwork() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      if (wifiName == null) return false;
      
      // Add your known network names here
      final knownNetworks = [
        'Avicast_Local',
        'Avicast_Office',
        'Avicast_Field',
        'Office_WiFi',
        'Field_Network',
      ];
      
      return knownNetworks.any((network) => 
          wifiName.toLowerCase().contains(network.toLowerCase()));
    } catch (e) {
      return false;
    }
  }
} 