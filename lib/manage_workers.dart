import 'package:flutter/material.dart';

class ManageWorkers extends StatelessWidget {
  const ManageWorkers({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Workers')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                Icons.engineering,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Worker $index',
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Pending',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    color: theme.colorScheme.primary,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.block),
                    color: theme.colorScheme.error,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
