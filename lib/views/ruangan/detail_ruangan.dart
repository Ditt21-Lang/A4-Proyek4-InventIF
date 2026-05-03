import 'package:flutter/material.dart';

import '../../controllers/ruangan/detail_ruangan_controller.dart';

class DetailRuanganScreen extends StatelessWidget {
  final DetailRuanganController controller;

  const DetailRuanganScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _RoomDetailBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Room',
                    style: TextStyle(
                      color: Color(0xFF8D8D8D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Details',
                      style: TextStyle(
                        color: Color(0xFFFF7A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _PhotoSection(),
                  const SizedBox(height: 20),
                  _DescriptionSection(controller: controller),
                  const SizedBox(height: 24),
                  _CalendarButton(
                    onTap: () => controller.openCalendar(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                image: AssetImage('assets/images/polban_zoom.jpeg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: const Color(0xFF222779).withValues(alpha: 0.78),
          ),
        ),
        Positioned(
          bottom: 14,
          left: 92,
          right: 92,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
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
                color: Colors.black.withValues(alpha: 0.75),
                blurRadius: 12,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFFFF7A1A),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection();

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      height: 176,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Photos'),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                const Expanded(child: _PhotoPlaceholder()),
                const SizedBox(width: 10),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFFF7A1A),
                  size: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE7E8F1),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFD3D5E2)),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF8C90A8), size: 42),
        ),
      ),
    );
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFFF7A1A),
                size: 17,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'View Calendar',
                  style: TextStyle(
                    color: Color(0xFFFF7A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFFF7A1A),
                size: 28,
              ),
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFF7A1A),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      '* $text',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
