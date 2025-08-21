import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info_plus;

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<String?> get wifiName;
  Future<String?> get wifiIPAddress;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final network_info_plus.NetworkInfo networkInfo;

  NetworkInfoImpl({
    required this.connectivity,
    required this.networkInfo,
  });

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<String?> get wifiName async {
    try {
      return await networkInfo.getWifiName();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> get wifiIPAddress async {
    try {
      return await networkInfo.getWifiIP();
    } catch (e) {
      return null;
    }
  }
} 