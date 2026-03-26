import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/encryption_service.dart';
import '../providers/file_provider.dart';
import '../utils/helpers.dart';

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({super.key});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  File? _selectedFile;
  String? _fileName;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _encrypt() async {
    if (_selectedFile == null) {
      Helpers.showSnackBar(context, 'Select a file');
      return;
    }
    if (_passwordController.text.isEmpty) {
      Helpers.showSnackBar(context, 'Enter password');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      Helpers.showSnackBar(context, 'Passwords do not match');
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Encrypting...'),
            ],
          ),
        ),
      );
      
      final encrypted = await EncryptionService.encryptFile(
        file: _selectedFile!,
        password: _passwordController.text,
      );
      
      if (context.mounted) Navigator.pop(context);
      await Provider.of<FileProvider>(context, listen: false).addFile(encrypted);
      
      if (context.mounted) {
        Helpers.showSnackBar(context, 'File encrypted!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      Helpers.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypt File')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile == null ? 'Select File' : 'Change File'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 50, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(_fileName!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _encrypt,
              icon: const Icon(Icons.lock),
              label: Text(_isProcessing ? 'Processing...' : 'Encrypt'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
