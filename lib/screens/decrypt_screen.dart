import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/encryption_service.dart';
import '../utils/helpers.dart';

class DecryptScreen extends StatefulWidget {
  final dynamic initialFile;
  const DecryptScreen({super.key, this.initialFile});

  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  File? _selectedFile;
  final _passwordController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFile != null) {
      _selectedFile = File(widget.initialFile.encryptedPath);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowedExtensions: ['enc']);
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _decrypt() async {
    if (_selectedFile == null) {
      Helpers.showSnackBar(context, 'Select encrypted file');
      return;
    }
    if (_passwordController.text.isEmpty) {
      Helpers.showSnackBar(context, 'Enter password');
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
              const Text('Decrypting...'),
            ],
          ),
        ),
      );
      
      final decrypted = await EncryptionService.decryptFile(
        encryptedFile: _selectedFile!,
        password: _passwordController.text,
      );
      
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: Text('File saved at:\n${decrypted.path}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      Helpers.showSnackBar(context, 'Failed: $e', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decrypt File')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open),
              label: Text(_selectedFile == null ? 'Select .enc File' : 'Change'),
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
                    const Icon(Icons.lock, size: 50, color: Colors.orange),
                    const SizedBox(height: 10),
                    Text(_selectedFile!.path.split('/').last),
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
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _decrypt,
              icon: const Icon(Icons.lock_open),
              label: Text(_isProcessing ? 'Processing...' : 'Decrypt'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
