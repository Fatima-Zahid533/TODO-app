import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'theme_provider.dart';
import 'task_provider.dart';
import 'api_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final userModel = ref.watch(userModelProvider).value;
    final allTasks = ref.watch(tasksProvider).value?? [];
    final completed = allTasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user?.photoURL!= null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  userModel?.displayName?? user?.displayName?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(user?.email?? '', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Total', allTasks.length),
                  _statItem('Done', completed),
                  _statItem('Pending', allTasks.length - completed),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Theme toggle
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authServiceProvider).signOut(),
          ),
          // Delete account
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will permanently delete all your tasks. Cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).deleteAccount();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}