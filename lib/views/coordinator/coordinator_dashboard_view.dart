import 'package:flutter/material.dart';
import '../../controllers/coordinator/coordinator_dashboard_controller.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import 'room_list_view.dart';

class CoordinatorDashboardView extends StatefulWidget {
  final UserModel? userData; // Menerima data dari Main Dashboard

  const CoordinatorDashboardView({super.key, this.userData});

  @override
  State<CoordinatorDashboardView> createState() =>
      _CoordinatorDashboardViewState();
}

class _CoordinatorDashboardViewState extends State<CoordinatorDashboardView> {
  final CoordinatorDashboardController _controller =
      CoordinatorDashboardController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://drive.google.com/uc?id=14huLMCPbDYsCMkOrzIo3hezQVcpN6dHN&export=download'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF283593).withValues(alpha: 0.85),
                  const Color(0xFF1A237E).withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header: Greeting + Profile
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello,',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Coordinator ${widget.userData?.nickname?.isNotEmpty == true ? widget.userData!.nickname! : widget.userData?.fullName ?? 'User'}!',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person,
                            color: Colors.grey, size: 36),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Room Submission (Today)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // List of Submissions
                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _controller.getTodayRoomSubmissions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white)));
                      }

                      final submissions = snapshot.data ?? [];

                      if (submissions.isEmpty) {
                        return Center(
                          child: Text('No room submissions today',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 16)),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom:
                                100 + MediaQuery.of(context).padding.bottom),
                        itemCount: submissions.length,
                        itemBuilder: (context, index) {
                          return _buildSubmissionCard(
                              submissions[index], context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // TOMBOL MELAYANG MENGELOLA RUANGAN
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 90.0), // Jarak aman agar tidak menabrak Navigasi Bawah
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFFF8A2A),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RoomListView()));
          },
          child: const Icon(Icons.meeting_room_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(
      TransactionModel submission, BuildContext context) {
    return GestureDetector(
      onTap: () => _showTransactionDetail(submission),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${submission.borrowerName}',
                          style: const TextStyle(
                              color: Color(0xFF283593),
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(submission.itemNames,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
                text: TextSpan(children: [
              const TextSpan(
                  text: 'Room: ',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextSpan(
                  text: submission.itemNames,
                  style: const TextStyle(
                      color: Color(0xFF283593),
                      fontSize: 12,
                      fontWeight: FontWeight.w600))
            ])),
            const SizedBox(height: 8),
            RichText(
                text: TextSpan(children: [
              const TextSpan(
                  text: 'Items: ',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextSpan(
                  text: submission.itemNames.isNotEmpty
                      ? submission.itemNames
                      : 'No items',
                  style: const TextStyle(
                      color: Color(0xFF283593),
                      fontSize: 12,
                      fontWeight: FontWeight.w600))
            ])),
            const SizedBox(height: 12),
            // Menghapus tombol konfirmasi. Sebagai ganti, tampilkan status saja
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(submission.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  submission.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(submission.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showTransactionDetail(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Borrower', transaction.borrowerName),
              _detailRow('Room', transaction.itemNames),
              _detailRow('Status', transaction.status),
              _detailRow('Event', transaction.eventName ?? '-'),
              _detailRow('Purpose', transaction.details),
              _detailRow('Time', '${_controller.formatTanggal(transaction.startDate)} - ${_controller.formatTanggal(transaction.endDate)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFFF8A2A))),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in use':
        return Colors.green;
      case 'completed':
        return Colors.blueGrey;
      case 'booked':
        return Colors.blue;
      default:
        return const Color(0xFFFF8A2A);
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
