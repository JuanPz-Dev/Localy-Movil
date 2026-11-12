import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../auth/login_view.dart';
import '../home/home_view.dart';
import '../map/map_view.dart';
import '../../screens/tour/reservation/my_reservations_view.dart';

class MainView extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MainView({
    super.key,
    required this.userData,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  static const Color primaryColor = Color(0xFF075E59);

  int selectedIndex = 0;

  void _logout() {
    ApiService.accessToken = null;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeView(userData: widget.userData),
      const MapView(),
      const MyReservationsView(),
      _ProfileView(
        userData: widget.userData,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCEDE9),
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const _ProfileView({
    required this.userData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'Usuario';
    final lastName = userData['lastName'] ?? '';
    final email = userData['email'] ?? 'Sin correo';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4ED),
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: const Color(0xFF075E59),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFDCEDE9),
              child: Icon(
                Icons.person,
                size: 55,
                color: Color(0xFF075E59),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$name $lastName'.trim(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email.toString(),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: Colors.red.shade200),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
