import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/coordinator/coordinator_dashboard_controller.dart';
import '../../models/transaction_model.dart';
import '../../controllers/Teknisi/export_controller.dart';
import '../../widgets/export_history_dialog.dart';
import '../../services/cloudinary_service.dart';
import '../Teknisi/document_viewer_view.dart';

class CoordinatorHistoryView extends StatefulWidget {
  const CoordinatorHistoryView({super.key});

  @override
  State<CoordinatorHistoryView> createState() => _CoordinatorHistoryViewState();
}

class _CoordinatorHistoryViewState extends State<CoordinatorHistoryView> {
  final CoordinatorDashboardController _controller = CoordinatorDashboardController();
  final ExportController _exportController = ExportController();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'In Use'; // Default tab
  bool _isUploading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLetter(TransactionModel item) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      File file = File(result.files.single.path!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading document to Cloudinary...')),
        );
      }

      String? url = await _cloudinaryService.uploadFile(file, 'official_letters');
      if (url != null) {
        try {
          await _controller.uploadOfficialLetter(item, url);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload successful!'), backgroundColor: Colors.green),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save URL: $e'), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload to Cloudinary failed!'), backgroundColor: Colors.red),
          );
        }
      }
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
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
              // Header: History Title & Export Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ExportHistoryDialog(
                            exportController: _exportController,
                            category: 'room',
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          color: Color(0xFFF78233), // Orange color
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      suffixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Tabs: In Use / History
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterTab('In Use', 'In Use'),
                    const SizedBox(width: 10),
                    _buildFilterTab('History', 'History'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),

              // History List
              Expanded(
                child: StreamBuilder<List<TransactionModel>>(
                  stream: _controller.getRoomSubmissionHistory(),
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

                    final allHistory = snapshot.data ?? [];
                    
                    // Filter based on Tab
                    List<TransactionModel> filteredList;
                    if (_selectedStatus == 'In Use') {
                      filteredList = allHistory.where((tx) => tx.status.toLowerCase() != 'completed').toList();
                    } else {
                      filteredList = allHistory.where((tx) => tx.status.toLowerCase() == 'completed').toList();
                    }

                    // Search filter
                    if (_searchController.text.isNotEmpty) {
                      final query = _searchController.text.toLowerCase();
                      filteredList = filteredList.where((tx) {
                        return tx.borrowerName.toLowerCase().contains(query) ||
                               tx.itemNames.toLowerCase().contains(query);
                      }).toList();
                    }

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          'No room submission history',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(filteredList[index]);
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

  Widget _buildFilterTab(String title, String status) {
    bool isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF78233) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(TransactionModel item) {
    return GestureDetector(
      onTap: () => _showTransactionDetail(item),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                    'https://i2.wp.com/images.genshin-builds.com/genshin/characters/furina/image.png?strip=all&quality=100&w=100'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${item.borrowerName}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      item.itemNames,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tombol Upload / Lihat Surat Resmi
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  if (item.officialLetterUrl != null && item.officialLetterUrl!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentViewerView(url: item.officialLetterUrl!),
                      ),
                    );
                  } else {
                    _pickAndUploadLetter(item);
                  }
                },
                icon: Icon(
                  item.officialLetterUrl != null ? Icons.description_rounded : Icons.upload_file_rounded,
                  color: Colors.blue,
                ),
                label: Text(
                  item.officialLetterUrl != null ? 'View Loan Letter' : 'Upload Loan Letter',
                  style: const TextStyle(
                    color: Colors.blue, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          
          // Original dokumen attachment (if any)
          if (item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentViewerView(url: item.attachmentUrl!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.attachment_rounded, color: Colors.blueGrey),
                  label: const Text('View Document (From Borrower)',
                      style: TextStyle(
                          color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        title: const Text('Room Booking Details', style: TextStyle(fontWeight: FontWeight.bold)),
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
              _detailRow(
                'Start Time',
                '${transaction.startDate.day}/${transaction.startDate.month}/${transaction.startDate.year} ${transaction.startDate.hour.toString().padLeft(2, '0')}:${transaction.startDate.minute.toString().padLeft(2, '0')}',
              ),
              _detailRow(
                'End Time',
                '${transaction.endDate.day}/${transaction.endDate.month}/${transaction.endDate.year} ${transaction.endDate.hour.toString().padLeft(2, '0')}:${transaction.endDate.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFF78233))),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
