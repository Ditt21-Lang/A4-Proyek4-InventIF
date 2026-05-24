import 'package:flutter/material.dart';
import '../../controllers/coordinator_dashboard_controller.dart';
import '../../models/transaction_model.dart';

class CoordinatorHistoryView extends StatefulWidget {
  const CoordinatorHistoryView({super.key});

  @override
  State<CoordinatorHistoryView> createState() => _CoordinatorHistoryViewState();
}

class _CoordinatorHistoryViewState extends State<CoordinatorHistoryView> {
  final CoordinatorDashboardController _controller =
      CoordinatorDashboardController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTanggalWaktu(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'Mar $day, $month:00 - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://drive.google.com/file/d/14huLMCPbDYsCMkOrzIo3hezQVcpN6dHN/view?usp=sharing',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF283593).withOpacity(0.85),
                const Color(0xFF1A237E).withOpacity(0.95),
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
              // Header: History Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // History List
              Expanded(
                child: StreamBuilder<List<TransactionModel>>(
                  stream: _searchController.text.isEmpty
                      ? _controller.getRoomSubmissionHistory()
                      : _controller
                          .searchRoomSubmissionHistory(_searchController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final history = snapshot.data ?? [];

                    if (history.isEmpty) {
                      return Center(
                        child: Text(
                          'No room submission history',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return _buildHistoryCard(item);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(TransactionModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Avatar
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                backgroundImage: const NetworkImage(
                  'https://via.placeholder.com/48',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${item.borrowerName}',
                      style: const TextStyle(
                        color: Color(0xFF283593),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTanggalWaktu(item.startDate),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Room info
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Room: ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: item.itemNames,
                  style: const TextStyle(
                    color: Color(0xFF283593),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Items info
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Items: ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: item.itemNames.isNotEmpty
                      ? item.itemNames
                      : 'No items',
                  style: const TextStyle(
                    color: Color(0xFF283593),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
