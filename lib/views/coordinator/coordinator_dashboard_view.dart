import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/coordinator_dashboard_controller.dart';
import '../../controllers/auth/login_controller.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import 'coordinator_history_view.dart';
import '../profile/userProfile_view.dart';
import '../auth/login_view.dart';

class CoordinatorDashboardView extends StatefulWidget {
  const CoordinatorDashboardView({super.key});

  @override
  State<CoordinatorDashboardView> createState() =>
      _CoordinatorDashboardViewState();
}

class _CoordinatorDashboardViewState extends State<CoordinatorDashboardView> {
  final CoordinatorDashboardController _controller =
      CoordinatorDashboardController();
  final LoginController _authController = LoginController();
  int _bottomNavIndex = 0;
  late final PageController _pageController;
  bool _isAuthorized = false;
  bool _isLoading = true;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _checkAuthorizationAndRole();
  }

  /// Check if user is logged in and has coordinator role
  Future<void> _checkAuthorizationAndRole() async {
    try {
      final currentUser = _authController.getCurrentUser();

      if (currentUser == null) {
        // User is not logged in
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      // Get user data from Firestore to check role
      final userData = await _authController.getUserDataFromFirestore(currentUser.uid);

      if (userData == null || userData.role != 'coordinator') {
        // User does not have coordinator role
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access denied! You must login as a coordinator.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          // Redirect to login after 2 seconds
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
        return;
      }

      // User authorized
      setState(() {
        _userData = userData;
        _isAuthorized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking authorization: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() => _bottomNavIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _formatTanggal(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return 'Mar $day, $month:00 - Mar $day, ${int.parse(date.hour.toString()) + 1}:00';
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking authorization
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    // Show error if not authorized
    if (!_isAuthorized) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: Text(
              'Access Denied',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _bottomNavIndex = index);
        },
        children: [
          // Dashboard Page
          _buildDashboardPage(),
          // History Page
          const CoordinatorHistoryView(),
          // Profile Page
          UserProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardPage() {
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
              // Header: Greeting + Profile
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo,',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Coordinator ${_userData?.nickname?.isNotEmpty == true ? _userData!.nickname! : _userData?.fullName ?? 'User'}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Image (circular)
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: const NetworkImage(
                        'https://via.placeholder.com/64',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Title: Room Submission (Today)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Room Submission (Today)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // List of Submissions
              Expanded(
                child: StreamBuilder<List<TransactionModel>>(
                  stream: _controller.getTodayRoomSubmissions(),
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

                    final submissions = snapshot.data ?? [];

                    if (submissions.isEmpty) {
                      return Center(
                        child: Text(
                          'No room submissions today',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final submission = submissions[index];
                        return _buildSubmissionCard(submission, context);
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

  Widget _buildSubmissionCard(
      TransactionModel submission, BuildContext context) {
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
                      'Name: ${submission.borrowerName}',
                      style: const TextStyle(
                        color: Color(0xFF283593),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.itemNames,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
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
                  text: submission.itemNames,
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
                  text: submission.itemNames.isNotEmpty
                      ? submission.itemNames
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
          const SizedBox(height: 12),
          // Confirm Button
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
                      'Confirm room submission from ${submission.borrowerName}?',
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
                    await _controller.confirmSubmission(submission);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Submission confirmed'),
                          backgroundColor: Colors.green,
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
                backgroundColor: const Color(0xFFFF9500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Confirm submission',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF9500),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: _bottomNavIndex == 0 ? 28 : 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              size: _bottomNavIndex == 1 ? 28 : 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: _bottomNavIndex == 2 ? 28 : 24,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
