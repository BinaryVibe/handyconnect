import 'package:flutter/material.dart';
import 'manage_users.dart';
import 'manage_workers.dart';
import 'admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _adminCard(
              context,
              icon: Icons.people,
              label: 'Manage Users',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsers()),
              ),
            ),
            _adminCard(
              context,
              icon: Icons.engineering,
              label: 'Manage Workers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageWorkers()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: theme.cardTheme.shape as BorderRadius?,
      onTap: onTap,
      child: Card(
        elevation: theme.cardTheme.elevation ?? 2,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
