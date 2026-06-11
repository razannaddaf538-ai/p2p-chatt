import 'package:flutter/material.dart';
import 'app_colors.dart';

class PeersScreen extends StatelessWidget {
  PeersScreen({Key? key}) : super(key: key);

  final List<String> peers = [
    "peer_1",
    "peer_2",
    "peer_3",
    "peer_4",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اكتشاف الأقران'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),

      body: ListView.builder(
        itemCount: peers.length,
        itemBuilder: (_, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(peers[index]),
              subtitle: Text('192.168.1.${index + 1}'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جاري الاتصال بـ ${peers[index]}')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                ),
                child: const Text('اتصال'),
              ),
            ),
          );
        },
      ),
    );
  }
}
