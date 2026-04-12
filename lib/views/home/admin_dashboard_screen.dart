import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notification_viewmodel.dart';
import 'admin_order_screen.dart';
import 'admin_qris_screen.dart';
import '../profile/admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  Timer? _notificationTimer;

  final List<Widget> _screens = [
    const AdminOrderScreen(),
    const AdminQrisScreen(),
    const AdminProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        Provider.of<NotificationViewModel>(
          context,
          listen: false,
        ).fetchUnreadNotifications();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationViewModel>(
        context,
        listen: false,
      ).fetchUnreadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    Provider.of<NotificationViewModel>(
      context,
      listen: false,
    ).fetchUnreadNotifications();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCED8AF),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFFCED8AF),
          selectedItemColor: const Color(0xFF35542E),
          unselectedItemColor: const Color(0xFF7CA66D),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_2), label: 'QRIS'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
