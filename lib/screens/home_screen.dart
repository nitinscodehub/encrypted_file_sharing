import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'encrypt_screen.dart';
import 'decrypt_screen.dart';
import 'settings_screen.dart';
import '../providers/file_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureShare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Consumer<FileProvider>(
        builder: (context, fileProvider, _) {
          if (fileProvider.files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text('No encrypted files', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EncryptScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Encrypt File'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fileProvider.files.length,
            itemBuilder: (context, index) {
              final file = fileProvider.files[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Helpers.getFileIcon(file.fileType), color: Colors.green),
                  title: Text(file.originalName, maxLines: 1),
                  subtitle: Text('${Helpers.formatFileSize(file.encryptedSize)}'),
                  trailing: const Icon(Icons.lock, color: Colors.orange),
                  onTap: () => _showOptions(context, file),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EncryptScreen()),
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showOptions(BuildContext context, dynamic file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_open, color: Colors.green),
              title: const Text('Decrypt'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DecryptScreen(initialFile: file)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(context, file.id);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _deleteFile(BuildContext context, String fileId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<FileProvider>(context, listen: false).deleteFile(fileId);
      if (context.mounted) {
        Helpers.showSnackBar(context, 'File deleted');
      }
    }
  }
}
