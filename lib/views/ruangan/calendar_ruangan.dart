import 'package:flutter/material.dart';

import '../../controllers/ruangan/calendar_ruangan_controller.dart';
import '../../models/transaction_model.dart';

class CalendarRuanganScreen extends StatelessWidget {
  final CalendarRuanganController controller;

  const CalendarRuanganScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_gedung.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          color: const Color(0xFF222779).withValues(alpha: 0.82),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return RefreshIndicator(
                  onRefresh: controller.fetchBookings,
                  color: const Color(0xFFF78233),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          roomName: controller.room.name,
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 22),
                        _MonthSelector(controller: controller),
                        const SizedBox(height: 18),
                        _CalendarGrid(controller: controller),
                        const SizedBox(height: 18),
                        _SelectedDatePanel(controller: controller),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF78233),
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Form request ${controller.room.name} belum tersedia',
              ),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String roomName;
  final VoidCallback onBack;

  const _Header({required this.roomName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'View Calendar',
          style: TextStyle(
            color: Color(0xFFB7B7C9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _IconButton(onTap: onBack, icon: Icons.chevron_left_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                roomName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final CalendarRuanganController controller;

  const _MonthSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(
          onTap: controller.showPreviousMonth,
          icon: Icons.chevron_left_rounded,
        ),
        Expanded(
          child: Center(
            child: Text(
              '${_monthName(controller.focusedMonth.month)} ${controller.focusedMonth.year}',
              style: const TextStyle(
                color: Color(0xFFFF8A2A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _IconButton(
          onTap: controller.showNextMonth,
          icon: Icons.chevron_right_rounded,
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final CalendarRuanganController controller;

  const _CalendarGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const SizedBox(
        height: 320,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFF78233)),
        ),
      );
    }

    final days = _visibleCalendarDays(controller.focusedMonth);

    return Column(
      children: [
        const Row(
          children: [
            _WeekdayLabel('Mo'),
            _WeekdayLabel('Tu'),
            _WeekdayLabel('We'),
            _WeekdayLabel('Th'),
            _WeekdayLabel('Fr'),
            _WeekdayLabel('Sa'),
            _WeekdayLabel('Su'),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 6,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final date = days[index];
            final isCurrentMonth = date.month == controller.focusedMonth.month;
            final isSelected = _isSameDate(date, controller.selectedDate);
            final hasBooking = controller.hasBookingOn(date);

            return _DateTile(
              date: date,
              isCurrentMonth: isCurrentMonth,
              isSelected: isSelected,
              hasBooking: hasBooking,
              onTap: () => controller.selectDate(date),
            );
          },
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFF8A2A),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool hasBooking;
  final VoidCallback onTap;

  const _DateTile({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.hasBooking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF8A2A).withValues(alpha: 0.24)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: const Color(0xFFFF8A2A), width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  color: isCurrentMonth ? Colors.white : Colors.white38,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              if (hasBooking)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8A2A),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDatePanel extends StatelessWidget {
  final CalendarRuanganController controller;

  const _SelectedDatePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bookings = controller.selectedDateBookings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3192),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.selectedDate.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_weekdayName(controller.selectedDate.weekday)}, ${_monthName(controller.selectedDate.month)} ${controller.selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white70),
          const SizedBox(height: 12),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Belum ada jadwal untuk tanggal ini',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            for (final booking in bookings) ...[
              _BookingItem(booking: booking),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final TransactionModel booking;

  const _BookingItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFFFF8A2A),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.borrowerName,
                style: const TextStyle(
                  color: Color(0xFFFF8A2A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                booking.details,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_formatTime(booking.startDate)} - ${_formatTime(booking.endDate)}',
                style: const TextStyle(
                  color: Color(0xFFFFB179),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(status: booking.status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF65E6A4);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFFFC36A);
    }
  }
}

class _IconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _IconButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF33349B),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFFF8A2A), size: 30),
        ),
      ),
    );
  }
}

List<DateTime> _visibleCalendarDays(DateTime focusedMonth) {
  final firstDay = DateTime(focusedMonth.year, focusedMonth.month);
  final startOffset = firstDay.weekday - DateTime.monday;
  final gridStart = firstDay.subtract(Duration(days: startOffset));

  return List.generate(42, (index) => gridStart.add(Duration(days: index)));
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _monthName(int month) {
  const names = [
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

  return names[month - 1];
}

String _weekdayName(int weekday) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return names[weekday - 1];
}
