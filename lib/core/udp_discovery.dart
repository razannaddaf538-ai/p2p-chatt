import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'peer.dart';

class UDPDiscovery {
  static const String multicastAddress = '224.0.0.251';
  static const int multicastPort = 43210;
  RawDatagramSocket? _socket;
  Timer? _announceTimer;
  final Duration announceInterval = const Duration(seconds: 3);
  final Map<String, Peer> _peers = {};
  final StreamController<List<Peer>> _peersCtrl = StreamController.broadcast();
  String name = 'P2P-Device';

  UDPDiscovery._private();
  static final UDPDiscovery instance = UDPDiscovery._private();

  Stream<List<Peer>> get peersStream => _peersCtrl.stream;
  List<Peer> get peers => _peers.values.toList();

  Future<void> start({String? deviceName, int? listenPort}) async {
    name = deviceName ?? name;
    if (_socket != null) return;
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, multicastPort, reuseAddress: true, reusePort: true);
      _socket!.joinMulticast(InternetAddress(multicastAddress));
      _socket!.listen(_onData, onError: (e) => print('Discovery socket error: $e'));

      _announceTimer = Timer.periodic(announceInterval, (_) => _announce(listenPort ?? 4040));
      // send immediate
      _announce(listenPort ?? 4040);
    } catch (e) {
      print('Failed to start UDP discovery: $e');
      rethrow;
    }
  }

  void _onData(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _socket!.receive();
    if (dg == null) return;
    try {
      final payload = utf8.decode(dg.data);
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final peer = Peer.fromMap(map);
      final key = peer.id;
      peer.lastSeen = DateTime.now();
      _peers[key] = peer;
      _peersCtrl.add(peers);
    } catch (e) {
      print('Discovery parse error: $e');
    }
  }

  void _announce(int port) {
    if (_socket == null) return;
    final msg = jsonEncode({'id': _localId(), 'name': name, 'ip': _localIp(), 'port': port, 'timestamp': DateTime.now().toIso8601String()});
    _socket!.send(utf8.encode(msg), InternetAddress(multicastAddress), multicastPort);
  }

  String _localIp() {
    try {
      for (var interface in NetworkInterface.listSync()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  String _localId() => '${_localIp()}';

  Future<void> stop() async {
    _announceTimer?.cancel();
    _announceTimer = null;
    _socket?.close();
    _socket = null;
    _peers.clear();
    _peersCtrl.add(peers);
  }
}
