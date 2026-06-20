import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'chatscreen.dart';

class PeersScreen extends StatelessWidget {
  final List peers = [
    "peer_1",
    "peer_2",
    "peer_3",
    "peer_4",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اكتشاف الأقران"),
      ),
      body: ListView.builder(
        itemCount: peers.length,
        itemBuilder: (_, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person),
              ),
              title: Text(peers[index]),
              subtitle: Text(
                "192.168.1.${index + 1}",
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen()),
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
