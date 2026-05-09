import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/git_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GitService _gitService = GitService();
  String? _selectedDirectory;
  String _consoleOutput = "Siap digunakan... Menunggu folder project dipilih.";
  
  final TextEditingController _commitController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  Future<void> _initSystem() async {
    await _gitService.initGit();
    setState(() {
      _isLoading = false;
      _consoleOutput = "Sistem Digitmoba berhasil diinisialisasi.";
    });
  }

  Future<void> _pickDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _selectedDirectory = directoryPath;
        _consoleOutput = "Folder aktif:\n$_selectedDirectory";
      });
    }
  }

  Future<void> _executeGit(List<String> args) async {
    if (_selectedDirectory == null) {
      setState(() => _consoleOutput = "Pilih folder project terlebih dahulu!");
      return;
    }
    
    setState(() => _consoleOutput = "Menjalankan git ${args.join(' ')}...\nMohon tunggu.");
    
    String result = await _gitService.runCommand(
      args, 
      _selectedDirectory!,
      token: _tokenController.text,
      username: _usernameController.text,
    );
    
    setState(() {
      if (result.trim().isEmpty) {
        _consoleOutput = "Perintah git ${args.join(' ')} berhasil dieksekusi tanpa output.";
      } else {
        _consoleOutput = result;
      }
    });
  }

  @override
  void dispose() {
    _commitController.dispose();
    _tokenController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Menyiapkan Binary Git...")
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digitmoba Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: Text(
                  _selectedDirectory == null 
                  ? 'Pilih Folder Project Flutter' 
                  : 'Ganti Folder Project'
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _pickDirectory,
              ),
              if (_selectedDirectory != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectedDirectory!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'GitHub Username', 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tokenController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Personal Access Token', 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _commitController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Pesan Commit', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _executeGit(['status']),
                    label: const Text('Status'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_box_outlined),
                    onPressed: () => _executeGit(['add', '.']),
                    label: const Text('Add All'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      if (_commitController.text.isEmpty) {
                        setState(() => _consoleOutput = "Pesan commit tidak boleh kosong!");
                        return;
                      }
                      _executeGit(['commit', '-m', _commitController.text]);
                    },
                    label: const Text('Commit'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _executeGit(['push', 'origin', 'main']),
                    label: const Text('Push (Main)'),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              const Text('Console Output:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _consoleOutput,
                    style: const TextStyle(
                      color: Colors.greenAccent, 
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}