import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/equipment_model.dart';
import '../../controllers/Teknisi/edit_equipment_controller.dart';

class EditEquipmentView extends StatefulWidget {
  final EquipmentModel equipment; // Menerima data alat yang akan diedit

  const EditEquipmentView({super.key, required this.equipment});

  @override
  State<EditEquipmentView> createState() => _EditEquipmentViewState();
}

class _EditEquipmentViewState extends State<EditEquipmentView> {
  final EditEquipmentController _controller = EditEquipmentController();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descController;

  String _selectedStatus = 'Available';
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Pre-fill formulir dengan data alat saat ini
    _idController = TextEditingController(text: widget.equipment.id);
    _nameController = TextEditingController(text: widget.equipment.name);
    _descController = TextEditingController(text: widget.equipment.description);

    // Pastikan status yang diterima valid untuk Dropdown
    List<String> validStatus = ['Available', 'In Use', 'Maintenance'];
    if (validStatus.contains(widget.equipment.status)) {
      _selectedStatus = widget.equipment.status;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri Foto'),
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 70);
                  if (pickedFile != null)
                    setState(() => _pickedImage = File(pickedFile.path));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera Ambil Foto'),
                onTap: () async {
                  final pickedFile = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (pickedFile != null)
                    setState(() => _pickedImage = File(pickedFile.path));
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
      bool success = await _controller.updateEquipment(
        id: _idController.text,
        name: _nameController.text,
        description: _descController.text,
        status: _selectedStatus,
        currentImageUrl: widget.equipment.image,
        newImageFile: _pickedImage,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Perubahan data "${_nameController.text}" berhasil disimpan!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke daftar alat
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal Menyimpan'),
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48.0),
                        child: Text('Edit Equipment',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 30 + MediaQuery.of(context).padding.bottom),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4))
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Informasi Aset Alat',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E))),
                          const Divider(color: Color(0xFFCFCFCF), thickness: 1),
                          const SizedBox(height: 16),

                          // UPLOAD IMAGE SELECTOR
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: const Color(0xFFC5CAE9), width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _pickedImage != null
                                    ? Image.file(_pickedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity) // Gambar Baru
                                    : (widget.equipment.image.isNotEmpty &&
                                            widget.equipment.image
                                                .startsWith('http'))
                                        ? Image.network(widget.equipment.image,
                                            fit: BoxFit.cover,
                                            width:
                                                double.infinity) // Gambar Lama
                                        : const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt_rounded,
                                                  size: 40,
                                                  color: Color(0xFF7986CB)),
                                              SizedBox(height: 8),
                                              Text(
                                                  'Ganti Gambar Alat (Opsional)',
                                                  style: TextStyle(
                                                      color: Color(0xFF7986CB),
                                                      fontSize: 12)),
                                            ],
                                          ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input ID (READ-ONLY)
                          _buildInputField(
                            label: 'Equipment ID / QR Code',
                            hint: '',
                            controller: _idController,
                            icon: Icons.qr_code_scanner_rounded,
                            isReadOnly: true, // DIKUNCI
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            label: 'Equipment Name',
                            hint: 'Masukkan nama alat',
                            controller: _nameController,
                            icon: Icons.handyman_rounded,
                          ),
                          const SizedBox(height: 16),

                          // STATUS DROPDOWN BARU
                          _buildStatusDropdown(),
                          const SizedBox(height: 16),

                          _buildInputField(
                            label: 'Description / Specification',
                            hint: 'Masukkan deskripsi...',
                            controller: _descController,
                            icon: Icons.description_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),

                          // Tombol Submit
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFFF78233),
                                      Color(0xFFE65100)
                                    ]),
                                    borderRadius: BorderRadius.circular(15),
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
                                            : const Text('UPDATE EQUIPMENT',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
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

  // Widget Status Dropdown
  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status Equipment',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDFDFDF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF7986CB)),
              items: ['Available', 'In Use', 'Maintenance'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        value == 'Available'
                            ? Icons.check_circle_rounded
                            : value == 'In Use'
                                ? Icons.access_time_filled_rounded
                                : Icons.build_circle_rounded,
                        size: 18,
                        color: value == 'Available'
                            ? Colors.green
                            : value == 'In Use'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null)
                  setState(() => _selectedStatus = newValue);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Komponen Input Field
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false, // Properti untuk mematikan field
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isReadOnly
                ? const Color(0xFFF5F5F5)
                : Colors.white, // Abu-abu jika mati
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDFDFDF)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: isReadOnly, // Nonaktifkan pengetikan jika true
            style: TextStyle(
                color: isReadOnly ? Colors.black54 : Colors.black87,
                fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
              prefixIcon: Icon(icon,
                  color: isReadOnly ? Colors.grey : const Color(0xFF7986CB),
                  size: 18),
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
