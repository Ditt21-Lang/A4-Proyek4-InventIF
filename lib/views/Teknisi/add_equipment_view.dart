// lib/views/Teknisi/add_equipment_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Membutuhkan package image_picker
import '../../controllers/Teknisi/add_equipment_controller.dart';

class AddEquipmentView extends StatefulWidget {
  const AddEquipmentView({super.key});

  @override
  State<AddEquipmentView> createState() => _AddEquipmentViewState();
}

class _AddEquipmentViewState extends State<AddEquipmentView> {
  final AddEquipmentController _controller = AddEquipmentController();
  final ImagePicker _picker = ImagePicker(); // Inisialisasi Image Picker

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  File? _pickedImage; // Variabel penampung file gambar yang dipilih

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar dari galeri/kamera
  Future<void> _pickImage() async {
    // Tampilkan opsi galeri/kamera menggunakan Bottom Sheet
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 70);
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera Take Photo'),
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    try {
      // Validasi wajib gambar
      if (_pickedImage == null) {
        throw Exception('Please select an equipment image first!');
      }

      bool success = await _controller.addEquipment(
        id: _idController.text,
        name: _nameController.text,
        description: _descController.text,
        pickedImage: _pickedImage, // Pass file gambar
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Equipment "${_nameController.text}" successfully added & uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke Dashboard
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to Add'),
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFF0F0F0), // Latar belakang abu-abu sangat muda khas Figma list
      body: Stack(
        children: [
          // 1. HEADER MELENGKUNG BIRU TUA (Meniru Figma image_229bb7.jpg)
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E), // Warna Biru Tua Figma
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. KONTEN UTAMA FORM
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Header Atas & Tombol Kembali
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48.0),
                        child: Text(
                          'Add New Equipment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Form Card Isian Data (Dibuat Clean dalam Card Putih)
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 30 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white, // Card Putih
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Equipment Asset Info',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E)),
                          ),
                          const Divider(color: Color(0xFFCFCFCF), thickness: 1),
                          const SizedBox(height: 16),

                          // === UPLOAD IMAGE SELECTOR === (MeniruPlaceholder image_229bb2.png)
                          GestureDetector(
                            onTap: _pickImage, // Klik untuk memilih gambar
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFFE8EAF6), // Biru tua muda sebagai placeholder
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: const Color(0xFFC5CAE9), width: 1.5),
                              ),
                              child: _pickedImage == null
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt_rounded,
                                            size: 40, color: Color(0xFF7986CB)),
                                        SizedBox(height: 8),
                                        Text(
                                          'Choose Equipment Image (Required)',
                                          style: TextStyle(
                                              color: Color(0xFF7986CB),
                                              fontSize: 12),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        _pickedImage!, // Pratinjau gambar yang dipilih
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Fields
                          _buildInputField(
                            label: 'Equipment ID / QR Code',
                            hint: 'LAB-IF-PRJ-001',
                            controller: _idController,
                            icon: Icons.qr_code_scanner_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            label: 'Equipment Name',
                            hint: 'e.g., Projector Lab A',
                            controller: _nameController,
                            icon: Icons.handyman_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            label: 'Description / Specification',
                            hint: 'Enter brief specification or location...',
                            controller: _descController,
                            icon: Icons.description_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),

                          // Tombol Submit Oranye Gradasi (Khas InventIF ACC/Checkout)
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF78233),
                                        Color(0xFFE65100)
                                      ], // Oranye khas
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        15), // Melengkung kotak khas Figma
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _controller.isLoading
                                          ? null
                                          : _handleSubmit,
                                      borderRadius: BorderRadius.circular(15),
                                      child: Center(
                                        child: _controller.isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white)
                                            : const Text(
                                                'SAVE EQUIPMENT',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Komponen Reusable Text Field Custom - Design Clean Figma
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFDFDFDF)), // Border abu-abu tipis
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
              prefixIcon: Icon(icon, color: const Color(0xFF7986CB), size: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
