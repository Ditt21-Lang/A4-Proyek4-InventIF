import 'package:flutter/material.dart';
import '../../controllers/ruangan/detail_ruangan_controller.dart';
import '../coordinator/edit_room_view.dart'; // Import halaman edit

class DetailRuanganScreen extends StatelessWidget {
  final DetailRuanganController controller;

  const DetailRuanganScreen({super.key, required this.controller});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ruangan'),
        content: Text(
            'Apakah Anda yakin ingin menghapus ruangan ${controller.title} secara permanen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteRoom();
                if (context.mounted) {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke list
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Ruangan berhasil dihapus!'),
                      backgroundColor: Colors.red));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Gagal menghapus ruangan'),
                      backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              const _RoomDetailBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24,
                      100), // Padding bottom ekstra agar tidak tertutup FAB
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Room',
                        style: TextStyle(
                            color: Color(0xFF8D8D8D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      // Header Buttons: Back (Kiri) dan Delete (Kanan - Jika Koordinator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BackButton(onTap: () => Navigator.pop(context)),
                          if (controller.isCoordinator)
                            _DeleteButton(
                                onTap: () => _showDeleteDialog(context)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Details',
                          style: TextStyle(
                              color: Color(0xFFFF7A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PhotoSection(imagePath: controller.imagePath),
                      const SizedBox(height: 20),
                      _DescriptionSection(controller: controller),
                      const SizedBox(height: 24),
                      _CalendarButton(
                          onTap: () => controller.openCalendar(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tombol Edit Melayang (Jika Koordinator)
          floatingActionButton: controller.isCoordinator
              ? FloatingActionButton.extended(
                  backgroundColor:
                      const Color(0xFFFFF5EE), // Warna Krem terang sesuai Figma
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditRoomView(room: controller.room)),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined,
                      color: Color(0xFF283593)), // Biru tua
                  label: const Text(
                    'Edit Details',
                    style: TextStyle(
                        color: Color(0xFF283593), fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        );
      },
    );
  }
}

// ==========================================
// WIDGET COMPONENTS (Background, Card, dll)
// ==========================================

class _RoomDetailBackground extends StatelessWidget {
  const _RoomDetailBackground();
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/bg_gedung.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center)))),
        Positioned.fill(
            child: Container(color: const Color(0xFF222779).withOpacity(0.78))),
        Positioned(
            bottom: 14,
            left: 92,
            right: 92,
            child: Container(
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)))),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: const Color(0xFF33349B),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.75),
                    blurRadius: 12,
                    offset: const Offset(3, 5))
              ]),
          child: const Icon(Icons.chevron_left_rounded,
              color: Color(0xFFFF7A1A), size: 30),
        ),
      ),
    );
  }
}

// Tombol Hapus Pojok Kanan Atas (Sesuai Figma)
class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: const Color(0xFFFFF5EE),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(3, 5))
              ]),
          child: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFFF7A1A), size: 26),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final String imagePath;
  const _PhotoSection({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      height: 176,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Photos'),
          const SizedBox(height: 6),
          // Panah chevron dihapus, gambar mengambil seluruh ruang yang tersedia
          Expanded(
            child: _RoomPhoto(imagePath: imagePath),
          ),
        ],
      ),
    );
  }
}

class _RoomPhoto extends StatelessWidget {
  final String imagePath;
  const _RoomPhoto({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFFE7E8F1),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFFD3D5E2))),
        clipBehavior: Clip.antiAlias,
        child: _buildImage(imagePath),
      ),
    );
  }

  Widget _buildImage(String url) {
    // Tambahkan width: double.infinity pada properti Image juga
    if (url.startsWith('http')) {
      return Image.network(url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_outlined,
                  color: Color(0xFF8C90A8), size: 42)));
    }
    return Image.asset(url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_outlined,
                color: Color(0xFF8C90A8), size: 42)));
  }
}

class _DescriptionSection extends StatelessWidget {
  final DetailRuanganController controller;
  const _DescriptionSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    final availableItems = controller.availableItems;
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Description'),
          const SizedBox(height: 8),
          _BulletText(controller.description),
          const SizedBox(height: 5),
          _BulletText('Mampu menampung hingga ${controller.capacity} orang'),
          if (availableItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            const _SectionTitle('Barang Tersedia'),
            const SizedBox(height: 8),
            for (final item in availableItems) ...[
              _BulletText(item),
              const SizedBox(height: 5),
            ],
          ],
        ],
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CalendarButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF5EE),
              borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: Color(0xFFFF7A1A), size: 17),
              SizedBox(width: 8),
              Expanded(
                  child: Text('View Calendar',
                      style: TextStyle(
                          color: Color(0xFFFF7A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700))),
              Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFFF7A1A), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;
  final double? height;
  const _DetailCard({required this.child, this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
            color: const Color(0xFFE8E4EF),
            borderRadius: BorderRadius.circular(14)),
        child: child);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: Color(0xFFFF7A1A),
            fontSize: 12,
            fontWeight: FontWeight.w700));
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text('• $text',
        style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight
                .w600)); // Mengubah bintang * menjadi titik bullet proper
  }
}
