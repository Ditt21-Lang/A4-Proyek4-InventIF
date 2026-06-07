import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/coordinator/add_room_controller.dart';

class AddRoomView extends StatefulWidget {
  const AddRoomView({super.key});

  @override
  State<AddRoomView> createState() => _AddRoomViewState();
}

class _AddRoomViewState extends State<AddRoomView> {
  final AddRoomController _controller = AddRoomController();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _capacityController =
      TextEditingController(); // TAMBAHAN BARU

  File? _pickedImage;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _capacityController.dispose(); // TAMBAHAN BARU
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
                title: const Text('Photo Gallery'),
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
                title: const Text('Camera Take Photo'),
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
      if (_pickedImage == null)
        throw Exception('Please select a room image first!');

      bool success = await _controller.addRoom(
        id: _idController.text,
        name: _nameController.text,
        capacity: _capacityController.text, // TAMBAHAN BARU
        description: _descController.text,
        pickedImage: _pickedImage,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Room successfully added!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48.0),
                        child: Text('Add New Room',
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
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Room Information',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E))),
                          const Divider(color: Color(0xFFCFCFCF), thickness: 1),
                          const SizedBox(height: 16),

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
                              child: _pickedImage == null
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt_rounded,
                                            size: 40, color: Color(0xFF7986CB)),
                                        SizedBox(height: 8),
                                        Text('Select Room Image',
                                            style: TextStyle(
                                                color: Color(0xFF7986CB),
                                                fontSize: 12)),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(_pickedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity)),
                            ),
                          ),
                          const SizedBox(height: 20),

                           _buildInputField(
                              label: 'Room ID',
                              hint: 'e.g., D-101',
                              controller: _idController,
                              icon: Icons.meeting_room_rounded),
                          const SizedBox(height: 16),
                          _buildInputField(
                              label: 'Room Name',
                              hint: 'e.g., Theory Room D-101',
                              controller: _nameController,
                              icon: Icons.class_rounded),
                          const SizedBox(height: 16),

                          // TAMBAHAN BARU: INPUT KAPASITAS (Angka saja)
                          _buildInputField(
                            label: 'Capacity (Maximum People)',
                            hint: 'e.g., 30',
                            controller: _capacityController,
                            icon: Icons.groups_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                              label: 'Description',
                              hint: 'Enter description...',
                              controller: _descController,
                              icon: Icons.description_rounded,
                              maxLines: 3),
                          const SizedBox(height: 32),

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
                                            : const Text('SAVE ROOM',
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

  // Fungsi Helper yang diubah untuk mendukung keyboardType (Khusus angka)
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text, // TAMBAHAN BARU
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDFDFDF)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType, // TAMBAHAN BARU
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
