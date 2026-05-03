import 'package:flutter/material.dart';
import '../../controllers/Teknisi/list_pengajuan_controller.dart';
import '../../models/Teknisi/transaksi_model.dart';

class ListPengajuanScreen extends StatefulWidget {
  const ListPengajuanScreen({super.key});

  @override
  State<ListPengajuanScreen> createState() => _ListPengajuanScreenState();
}

class _ListPengajuanScreenState extends State<ListPengajuanScreen> {
  final ListPengajuanController _controller = ListPengajuanController();
  
 
  String _selectedStatus = 'Pending'; 
  final int _selectedIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://drive.google.com/file/d/14huLMCPbDYsCMkOrzIo3hezQVcpN6dHN/view?usp=sharing'),
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
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text('Request List', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterTab('Pending', 'Pending'),
                      _buildFilterTab('Ready to Collect', 'Approved'),
                      _buildFilterTab('Borrowed', 'Borrowed'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<List<TransaksiModel>>(
                    stream: _controller.getFilteredStream(_selectedStatus),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
                      }

                      final listData = snapshot.data ?? [];

                      if (listData.isEmpty) {
                        return Center(
                          child: Text("Tidak ada data di kategori $_selectedStatus", style: const TextStyle(color: Colors.white70)),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          return _buildCard(listData[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFEBE5DF),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 0, '/dashboard-teknisi'),
                  _buildNavItem(Icons.content_paste_outlined, 1, '/list-pengajuan'),
                  _buildNavItem(Icons.person_outline, 2, ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterTab(String label, String statusDb) {
    bool isActive = _selectedStatus == statusDb;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = statusDb),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF48A42) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(TransaksiModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('https://i2.wp.com/images.genshin-builds.com/genshin/characters/furina/image.png?strip=all&quality=100&w=100'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${item.namaPeminjam}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Order ID: ${item.id}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Items:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text('• ${item.namaItem}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 16),
          if (_selectedStatus == 'Pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildButton('Reject', const [Color(0xFFE53935), Color(0xFFC62828)], () {
                  _controller.updateStatus(item.id, 'Rejected');
                }),
                _buildButton('Approve', const [Color(0xFFF48A42), Color(0xFFE65C00)], () {
                  _controller.updateStatus(item.id, 'Approved');
                }),
              ],
            )
          else if (_selectedStatus == 'Approved')
             Align(
               alignment: Alignment.centerRight,
               child: _buildButton('Borrowed', const [Color(0xFFF48A42), Color(0xFFE65C00)], () {
                 _controller.updateStatus(item.id, 'Borrowed');
               }),
             )
          else if (_selectedStatus == 'Borrowed')
             const Align(
               alignment: Alignment.centerRight,
               child: Text('Item is currently borrowed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
             )
        ],
      ),
    );
  }

  Widget _buildButton(String label, List<Color> gradientColors, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String routeName) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (!isActive && routeName.isNotEmpty) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF48A42) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.black87, size: 30),
      ),
    );
  }
}