import 'package:flutter/material.dart';

class BaseCatalogLayout extends StatelessWidget {
  final Widget child;
  const BaseCatalogLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ganti Scaffold jadi Container
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_gedung.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
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
