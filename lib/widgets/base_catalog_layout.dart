import 'package:flutter/material.dart';
import '../controllers/notifications_controller.dart';
import '../views/notifications/notifications_view.dart';

class BaseCatalogLayout extends StatelessWidget {
  final Widget child;
  const BaseCatalogLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_gedung.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          // Top-right notification bell
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedBuilder(
                  animation: NotificationsController.instance,
                  builder: (context, _) {
                    final unread = NotificationsController.instance.unreadCount;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NotificationsView()));
                          },
                          icon: const Icon(Icons.notifications,
                              color: Colors.white),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B3B98),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
