import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/Teknisi/export_controller.dart';

class ExportHistoryDialog extends StatefulWidget {
  final ExportController exportController;
  final String category;

  const ExportHistoryDialog({super.key, required this.exportController, this.category = 'equipment'});

  @override
  State<ExportHistoryDialog> createState() => _ExportHistoryDialogState();
}

class _ExportHistoryDialogState extends State<ExportHistoryDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFileType = 'Excel'; // Default

  final List<String> _fileTypes = ['Excel', 'PDF', 'Doc'];

  void _pickDate(bool isStart) async {
    DateTime initialDate = DateTime.now();
    if (isStart && _startDate != null) initialDate = _startDate!;
    if (!isStart && _endDate != null) initialDate = _endDate!;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030), // Mengizinkan eksport data di masa depan (tidak dibatasi hari ini)
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _export() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rentang tanggal terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal "To" tidak boleh sebelum "Starting From"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Await export process so it uses the mounted context
    await widget.exportController.exportTransactions(
      context: context,
      startDate: _startDate!,
      endDate: _endDate!,
      format: _selectedFileType.toLowerCase(),
      category: widget.category,
    );

    // After loading dialog is popped by exportTransactions, pop this dialog
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF283593), // Latar Biru
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Center(
              child: Text(
                'Export History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            const Text(
              'Pilih tanggal history yang mau di eksport',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Date Pickers Row
            Row(
              children: [
                Expanded(child: _buildDatePicker(true)),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePicker(false)),
              ],
            ),
            const SizedBox(height: 24),

            // Type File Dropdown
            const Text(
              'Type File',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDropdown(),
            
            const SizedBox(height: 32),

            // Export Button
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _export,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF78233), // Oranye
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Export',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isStart) {
    String label = isStart ? 'Starting From' : 'To';
    DateTime? selectedDate = isStart ? _startDate : _endDate;
    String dateStr = selectedDate != null
        ? DateFormat('dd/MM/yy').format(selectedDate)
        : 'dd/MM/yy';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      width: 140, // Match design proportion
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFileType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          dropdownColor: const Color(0xFFE0E0E0),
          isExpanded: true,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFileType = newValue;
              });
            }
          },
          items: _fileTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
