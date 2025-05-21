import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const DashboardScreen({super.key, required this.toggleTheme});

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('🌙 Дарк горим'),
            onTap: () {
              Navigator.pop(context);
              toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('🔔 Мэдэгдэл'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Мэдэгдэл идэвхжсэн')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('ℹ️ Аппын тухай'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Аппын тухай'),
                  content: const Text('Барилгын материалын захиалгын систем v1.0'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Lottie.asset(
            'assets/animation/zurag.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xAAFFF8E1), Color(0xAAFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.orange.shade700,
              title: const Text('Удирдлагын самбар', style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 4,
              shadowColor: Colors.black26,
              actions: [
                IconButton(
                  tooltip: 'Профайл',
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.orange),
                  ),
                ),
                IconButton(
                  tooltip: 'Гарах',
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _DashboardCard(
                  icon: Icons.shopping_bag,
                  label: 'Бүтээгдэхүүн',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/products'),
                ),
                _DashboardCard(
                  icon: Icons.settings,
                  label: 'Тохиргоо',
                  color: Colors.teal,
                  onTap: () => _showSettingsSheet(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.2),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
