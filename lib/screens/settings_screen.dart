import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/file_provider.dart';
import '../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Files', style: TextStyle(color: Colors.red)),
            onTap: () => _clearAllFiles(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('SecureShare v1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Encryption'),
            subtitle: Text('AES-256 Bit'),
          ),
        ],
      ),
    );
  }
  
  void _clearAllFiles(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Delete all encrypted files?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirm == true) {
      final fileProvider = Provider.of<FileProvider>(context, listen: false);
      for (var file in fileProvider.files.toList()) {
        await fileProvider.deleteFile(file.id);
      }
      if (context.mounted) {
        Helpers.showSnackBar(context, 'All files cleared');
        Navigator.pop(context);
      }
    }
  }
}
