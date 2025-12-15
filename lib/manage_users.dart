import 'package:flutter/material.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            elevation: theme.cardTheme.elevation,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'User $index',
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Customer',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Switch(
                value: true,
                onChanged: (_) {},
              ),
            ),
          );
        },
      ),
    );
  }
}
