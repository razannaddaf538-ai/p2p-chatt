# Enhanced P2P Engine & Multicast Discovery

This branch adds an enhanced P2P engine and multicast peer discovery, integrated with the Flutter UI in this repository.

What was added
- lib/core/p2p_message.dart
- lib/core/enhanced_p2p_chat_engine.dart
- lib/core/udp_discovery.dart (multicast discovery)
- lib/core/peer.dart
- Modified lib/chatscreen.dart to use the enhanced engine
- Modified lib/peersScreen.dart to use discovery and connect directly
- example/console_client.dart for non-Flutter testing

Quick setup
1. Add dependencies:
   flutter pub add uuid

2. Run the app on two devices on the same bridged network (ensure the network allows multicast).

3. Steps to test/demo:
- Start the app on both devices.
- The Peers screen should show discovered devices automatically.
- Tap "اتصال" to open chat with a peer (IP is prefilled).
- Send messages; the engine uses ACKs per message and will retry on failure.

Notes & Considerations
- This implementation uses length-prefixed framing to avoid TCP stream fragmentation issues.
- Each message carries a UUID and the receiver replies with an ACK message for reliability at the application layer.
- Multicast address: 224.0.0.251 and port: 43210 (you can change these in `udp_discovery.dart`).
- On Android you may need to request multicast locks for some devices/networks.

Authors
- Aya Darwish Ahmad
- Razan Naddaf

