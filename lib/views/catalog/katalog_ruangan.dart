import 'package:flutter/material.dart';
import 'package:inventif/views/catalog/detail_ruangan.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

enum FacilityType { room, equipment }

class Facility {
  final String name;
  final String description;
  final FacilityType type;
  final bool isAvailable;
  final int chairCount;
  final int capacity;

  const Facility({
    required this.name,
    required this.description,
    required this.type,
    required this.isAvailable,
    required this.chairCount,
    required this.capacity,
  });
}

final List<Facility> dummyFacilities = [
  Facility(
    name: 'Conference Room A',
    description: 'Capacity 20 people · 3rd Floor',
    type: FacilityType.room,
    isAvailable: true,
    chairCount: 20,
    capacity: 25,
  ),
  Facility(
    name: 'Meeting Room B',
    description: 'Capacity 10 people · 2nd Floor',
    type: FacilityType.room,
    isAvailable: false,
    chairCount: 10,
    capacity: 12,
  ),
  Facility(
    name: 'Training Room',
    description: 'Capacity 30 people · 1st Floor',
    type: FacilityType.room,
    isAvailable: true,
    chairCount: 30,
    capacity: 40,
  ),
  Facility(
    name: 'Discussion Room C',
    description: 'Capacity 8 people · 4th Floor',
    type: FacilityType.room,
    isAvailable: false,
    chairCount: 8,
    capacity: 10,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class KatalogRuanganScreen extends StatefulWidget {
  const KatalogRuanganScreen({super.key});

  @override
  State<KatalogRuanganScreen> createState() => _KatalogRuanganScreenState();
}

class _KatalogRuanganScreenState extends State<KatalogRuanganScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Facility> get _filteredFacilities {
    return dummyFacilities.where((f) {
      final matchSearch =
          _searchQuery.isEmpty ||
          f.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch && f.type == FacilityType.room;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Layer 1: Background gambar Polban (atas) + ungu (bawah) ──
          Column(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/polban_background.jpeg'),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF87CEEB), Color(0xFF4A90D9)],
                  ),
                ),
              ),
              // Sisa layar warna ungu
              Expanded(child: Container(color: const Color(0xFF2D2D6B))),
            ],
          ),

          // ── Layer 2: Konten utama (scrollable) ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacer agar konten turun ke bawah gambar langit
                const SizedBox(height: 120),

                // Card putih membulat yang menampung semua konten
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D6B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Text(
                            'Available Facilities',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildFilterChips(),
                        _buildSearchBar(),
                        // List mengisi sisa ruang
                        Expanded(child: _buildFacilityList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    final filters = ['All', 'Room', 'Equipment', 'Available'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isActive = i == 1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF4831F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search Facilities',
            hintStyle: TextStyle(color: Colors.black38),
            suffixIcon: Icon(Icons.search, color: Colors.black45, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── Facility List ─────────────────────────────────────────────────────────

  Widget _buildFacilityList() {
    final items = _filteredFacilities;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No rooms found',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }
    return ListView.builder(
      // shrinkWrap false + Expanded → list mengisi ruang yang tersedia, tidak ada gap kosong
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildFacilityCard(items[i]),
    );
  }

  Widget _buildFacilityCard(Facility facility) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailRuanganScreen(facility: facility),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.meeting_room_rounded,
                    color: Color(0xFF9999BB),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        facility.description,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: facility.isAvailable
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          facility.isAvailable ? 'Available' : 'In Use',
                          style: TextStyle(
                            color: facility.isAvailable
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav Bar ────────────────────────────────────────────────────────

  Widget _buildBottomNavBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded),
            _navItem(1, Icons.crop_square_rounded),
            _navItem(2, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    final isActive = index == 1;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF4831F) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.black45,
        size: 26,
      ),
    );
  }
}
