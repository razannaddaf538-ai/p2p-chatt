import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'chatscreen.dart';
import 'core/udp_discovery.dart';
import 'core/peer.dart';

class PeersScreen extends StatefulWidget {
  @override
  _PeersScreenState createState() => _PeersScreenState();
}

class _PeersScreenState extends State<PeersScreen> {
  List<Peer> _peers = [];

  @override
  void initState() {
    super.initState();
    UDPDiscovery.instance.start(deviceName: 'P2P-App');
    UDPDiscovery.instance.peersStream.listen((list) {
      setState(() => _peers = list);
    });
  }

  @override
  void dispose() {
    UDPDiscovery.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اكتشاف الأقران"),
      ),
      body: ListView.builder(
        itemCount: _peers.length,
        itemBuilder: (_, index) {
          final peer = _peers[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person),
              ),
              title: Text(peer.name),
              subtitle: Text(peer.ip),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen(initialTargetIp: peer.ip)),
                  );
                },
                child: const Text("اتصال"),
              ),
            ),
          );
        },
      ),
    );
  }
}
