import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/coordinator/edit_room_controller.dart';
import '../../models/room_model.dart';

class EditRoomView extends StatefulWidget {
  final RoomModel room;
  const EditRoomView({super.key, required this.room});

  @override
  State<EditRoomView> createState() => _EditRoomViewState();
}

class _EditRoomViewState extends State<EditRoomView> {
  final EditRoomController _controller = EditRoomController();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _capacityController;

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data ruangan saat ini
    _idController = TextEditingController(text: widget.room.id);
    _nameController = TextEditingController(text: widget.room.name);
    _descController = TextEditingController(text: widget.room.description);
    _capacityController = TextEditingController(text: widget.room.capacity);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _capacityController.dispose();
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
      bool success = await _controller.updateRoom(
        id: widget.room.id,
        name: _nameController.text,
        capacity: _capacityController.text,
        description: _descController.text,
        pickedImage: _pickedImage,
        oldImageUrl: widget.room.gambar,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Room updated successfully!'),
              backgroundColor: Colors.green),
        );
        // Kembali 2 kali untuk me-refresh List Data
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to Update'),
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
                        child: Text('Edit Room Details',
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
                              child: _pickedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(_pickedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: _buildNetworkImage(
                                          widget.room.gambar)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                              child: Text('Tap image to change',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey))),
                          const SizedBox(height: 20),

                          // ID di-disable agar tidak bisa diganti (ReadOnly)
                          _buildInputField(
                              label: 'Room ID',
                              hint: '',
                              controller: _idController,
                              icon: Icons.meeting_room_rounded,
                              isReadOnly: true),
                          const SizedBox(height: 16),
                           _buildInputField(
                              label: 'Room Name',
                              hint: 'e.g., Theory Room D-101',
                              controller: _nameController,
                              icon: Icons.class_rounded),
                          const SizedBox(height: 16),
                          _buildInputField(
                              label: 'Capacity (Maximum People)',
                              hint: 'e.g., 30',
                              controller: _capacityController,
                              icon: Icons.groups_rounded,
                              keyboardType: TextInputType.number),
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
                                            : const Text('UPDATE ROOM',
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

  Widget _buildNetworkImage(String url) {
    if (url.isEmpty)
      return const Center(
          child: Icon(Icons.meeting_room, size: 50, color: Colors.grey));
    if (url.startsWith('http'))
      return Image.network(url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey)));
    return Image.asset(url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)));
  }

  Widget _buildInputField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      required IconData icon,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      bool isReadOnly = false}) {
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
              color: isReadOnly ? Colors.grey[200] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDFDFDF))),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            readOnly: isReadOnly,
            style: TextStyle(
                color: isReadOnly ? Colors.grey : Colors.black87, fontSize: 13),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFFAFAFAF), fontSize: 12),
                prefixIcon:
                    Icon(icon, color: const Color(0xFF7986CB), size: 18),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          ),
        ),
      ],
    );
  }
}
