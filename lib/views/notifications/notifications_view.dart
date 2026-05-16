import 'package:flutter/material.dart';
import '../../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final _ctrl = NotificationsController.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF3B3B98),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              await _ctrl.clearAll();
            },
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final items = _ctrl.items;
          if (items.isEmpty) {
            return const Center(
                child: Text('No notifications',
                    style: TextStyle(color: Colors.white)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (c, i) {
              final n = items[i];
              return ListTile(
                tileColor:
                    n.read ? const Color(0xFFE6E2E6) : const Color(0xFFF78233),
                title: Text(n.title,
                    style: TextStyle(
                        color: n.read ? Colors.black87 : Colors.white)),
                subtitle: Text(n.body,
                    style: TextStyle(
                        color: n.read ? Colors.black54 : Colors.white70)),
                onTap: () async {
                  n.read = true;
                  await _ctrl.saveToStorage();
                  _ctrl.notifyListeners();
                },
              );
            },
            separatorBuilder: (c, i) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
