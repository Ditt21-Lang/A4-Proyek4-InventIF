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
  String? _selectedStatus;

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
                'https://drive.google.com/uc?id=14huLMCPbDYsCMkOrzIo3hezQVcpN6dHN&export=download',
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
              // Status Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip('All', null),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Waiting', 'Waiting'),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Pending', 'Pending'),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Confirmed', 'coordinator_confirmed'),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Completed', 'Completed'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // History List
              Expanded(
                child: StreamBuilder<List<TransactionModel>>(
                  stream: _selectedStatus != null
                      ? _controller.getRoomSubmissionHistoryByStatus(_selectedStatus)
                      : _controller.getRoomSubmissionHistory(),
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
    return GestureDetector(
      onTap: () => _showTransactionDetail(item),
      child: Container(
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
                  child: const Icon(Icons.person, color: Colors.grey, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.borrowerName,
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
            ),            const SizedBox(height: 12),
            // Confirm Button (only if status is Waiting)
            if (item.status.toLowerCase() == 'waiting')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Submission'),
                        content: Text(
                          'Confirm room submission from ${item.borrowerName}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await _controller.confirmSubmission(item);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Submission confirmed!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF78233),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Submission',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFF78233),
      side: BorderSide(
        color: isSelected ? const Color(0xFFF78233) : Colors.grey.shade300,
        width: 1.5,
      ),
    );
  }

  void _showTransactionDetail(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Detail'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Borrower', transaction.borrowerName),
              _detailRow('Room', transaction.itemNames),
              _detailRow('Status', transaction.status),
              _detailRow('Event', transaction.eventName ?? '-'),
              _detailRow('Details', transaction.details),
              _detailRow(
                'Start Date',
                '${transaction.startDate.day}/${transaction.startDate.month}/${transaction.startDate.year} ${transaction.startDate.hour}:${transaction.startDate.minute.toString().padLeft(2, '0')}',
              ),
              _detailRow(
                'End Date',
                '${transaction.endDate.day}/${transaction.endDate.month}/${transaction.endDate.year} ${transaction.endDate.hour}:${transaction.endDate.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
