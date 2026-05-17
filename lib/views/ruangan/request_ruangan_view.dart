import 'package:flutter/material.dart';

import '../../controllers/ruangan/request_ruangan_controller.dart';
import '../../models/equipment_model.dart';

class RequestRuanganScreen extends StatefulWidget {
  final RequestRuanganController controller;

  const RequestRuanganScreen({super.key, required this.controller});

  @override
  State<RequestRuanganScreen> createState() => _RequestRuanganScreenState();
}

class _RequestRuanganScreenState extends State<RequestRuanganScreen> {
  RequestRuanganController get controller => widget.controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final success = await controller.submitRequest();
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request room berhasil dikirim')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _showEquipmentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 0, 34, 76),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 330,
                      maxHeight: 520,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF302E98),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.32),
                          blurRadius: 14,
                          offset: const Offset(4, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 34, 24, 10),
                          child: _EquipmentPickerHeader(
                            date: controller.startDateTime,
                          ),
                        ),
                        Expanded(
                          child: _EquipmentPickerContent(
                            controller: controller,
                            onSelected: (equipment) {
                              controller.addEquipment(equipment);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF3432A1),
        child: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Form Room',
                      style: TextStyle(color: Color(0xFFBDBDE0), fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BackCircle(onTap: () => Navigator.pop(context)),
                            const SizedBox(height: 22),
                            const Center(
                              child: Text(
                                'Form Request Room',
                                style: TextStyle(
                                  color: Color(0xFFFF8A2A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                width: 208,
                                height: 2,
                                color: const Color(0xFF9EA1E4),
                              ),
                            ),
                            const SizedBox(height: 28),
                            const _Label('Event Name'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: controller.eventNameController,
                            ),
                            const SizedBox(height: 18),
                            const _Label('Description'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: controller.descriptionController,
                              minLines: 4,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 18),
                            const _Label('Date Time Start'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _PickerField(
                                    icon: Icons.calendar_today_outlined,
                                    text: _formatDate(controller.startDateTime),
                                    onTap: () =>
                                        controller.pickStartDate(context),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PickerField(
                                    icon: Icons.access_time_rounded,
                                    text: _formatTime(controller.startDateTime),
                                    onTap: () =>
                                        controller.pickStartTime(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const _Label('Date Time End'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _PickerField(
                                    icon: Icons.calendar_today_outlined,
                                    text: _formatDate(controller.endDateTime),
                                    onTap: () =>
                                        controller.pickEndDate(context),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PickerField(
                                    icon: Icons.access_time_rounded,
                                    text: _formatTime(controller.endDateTime),
                                    onTap: () =>
                                        controller.pickEndTime(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            _ActionColumn(
                              label: 'Upload Document',
                              child: _ActionButton(
                                icon: Icons.upload_outlined,
                                text: controller.documentLabel ??
                                    'Upload max 100mb',
                                onTap: () => controller.pickDocument(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ActionColumn(
                              label: 'Add Equipment',
                              child: _ActionButton(
                                icon: Icons.add_rounded,
                                text: controller.selectedEquipment.isEmpty
                                    ? 'Add (optional)'
                                    : '${controller.selectedEquipment.length} equipment selected',
                                onTap: _showEquipmentPicker,
                              ),
                            ),
                            if (controller.selectedEquipment.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ...controller.selectedEquipment.map(
                                (equipment) => _SelectedEquipmentCard(
                                  equipment: equipment,
                                  onRemove: () =>
                                      controller.removeEquipment(equipment),
                                ),
                              ),
                            ],
                            const SizedBox(height: 34),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    controller.isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF8A2A),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 10,
                                  shadowColor: Colors.black54,
                                ),
                                child: controller.isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Checkout',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Container(
                                width: 96,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day/$month/$year';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _BackCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _BackCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF33349B),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(2, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFFFF8A2A),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFF8A2A),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  const _InputField({
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD9D4DE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3DDE4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2E2E2E), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF5A5A5A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _ActionColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFF8A2A),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFE3DDE4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2E2E2E), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentPickerHeader extends StatelessWidget {
  final DateTime date;

  const _EquipmentPickerHeader({required this.date});

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              date.day.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                _weekdays[date.weekday - 1],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Container(height: 1.5, color: const Color(0xFFC5C2E7)),
        const SizedBox(height: 5),
        Text(
          '${_months[date.month - 1]} ${date.day}',
          style: const TextStyle(
            color: Color(0xFFC5C2E7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SelectedEquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback onRemove;

  const _SelectedEquipmentCard({
    required this.equipment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3DDE4),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Text(
                equipment.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
          ),
          Container(width: 1.5, color: const Color(0xFFB9B3BA)),
          SizedBox(
            width: 78,
            height: double.infinity,
            child: _EquipmentImage(equipment: equipment),
          ),
          SizedBox(
            width: 34,
            child: IconButton(
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentPickerContent extends StatelessWidget {
  final RequestRuanganController controller;
  final ValueChanged<EquipmentModel> onSelected;

  const _EquipmentPickerContent({
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingEquipment) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF8A2A)),
      );
    }

    if (controller.availableEquipment.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const SizedBox(height: 48),
          const Center(
            child: Text(
              'Equipment tersedia belum ada',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: TextButton.icon(
              onPressed: controller.fetchAvailableEquipment,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reload'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF8A2A),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
      itemCount: controller.availableEquipment.length,
      itemBuilder: (context, index) {
        final equipment = controller.availableEquipment[index];
        final isSelected = controller.isEquipmentSelected(equipment);

        return _EquipmentPickerRow(
          equipment: equipment,
          isSelected: isSelected,
          onTap: isSelected ? null : () => onSelected(equipment),
        );
      },
    );
  }
}

class _EquipmentPickerRow extends StatelessWidget {
  final EquipmentModel equipment;
  final bool isSelected;
  final VoidCallback? onTap;

  const _EquipmentPickerRow({
    required this.equipment,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isSelected ? 0.5 : 1,
          child: Container(
            height: 68,
            margin: const EdgeInsets.only(bottom: 1),
            child: Row(
              children: [
                SizedBox(
                  width: 62,
                  height: 42,
                  child: _EquipmentImage(equipment: equipment),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 58,
                  color: const Color(0xFFFF8A2A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFF8A2A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        equipment.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFF8A2A),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: const Color(0xFFC7F4FF),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EquipmentImage extends StatelessWidget {
  final EquipmentModel equipment;

  const _EquipmentImage({required this.equipment});

  @override
  Widget build(BuildContext context) {
    final image = equipment.image.trim();
    final fallback = Container(
      color: Colors.white,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Color(0xFF6A6A6A),
      ),
    );

    if (image.isEmpty) return fallback;

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
