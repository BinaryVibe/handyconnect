import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'manage_users.dart';
import 'manage_workers.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                'Administrator',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.people,
            label: 'Users',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsers()),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.engineering,
            label: 'Workers',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageWorkers()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      onTap: onTap,
    );
  }
}
