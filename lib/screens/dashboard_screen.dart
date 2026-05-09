import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/git_service.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GitService _gitService = GitService();
  String? _selectedDirectory;
  String _consoleOutput = "Siap digunakan... Menunggu instruksi.";
  
  final TextEditingController _commitController = TextEditingController();

  String _savedRepoUrl = "";
  String _savedToken = "";

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  // --- PERBAIKAN LOADING DISINI ---
  Future<void> _initSystem() async {
    try {
      await _gitService.initGit();
      await _loadSettingsData(); 
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _consoleOutput = "GAGAL INISIALISASI SISTEM:\n$e\n\nPastikan Anda sudah mendownload file Git di folder assets/bin/git !";
      });
    }
  }

  Future<void> _loadSettingsData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedRepoUrl = prefs.getString('repoUrl') ?? '';
      _savedToken = prefs.getString('token') ?? '';
      
      // Mencegah pesan error inisialisasi tertimpa oleh pesan peringatan
      if (!_consoleOutput.startsWith("GAGAL")) {
        if (_savedRepoUrl.isEmpty || _savedToken.isEmpty) {
          _consoleOutput = "PERINGATAN: Link Repository atau Token belum diatur!\nSilakan buka menu Pengaturan (ikon gear di pojok kanan atas).";
        } else {
          _consoleOutput = "Sistem siap.\nRepo aktif: $_savedRepoUrl";
        }
      }
    });
  }

  Future<void> _pickDirectory() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _selectedDirectory = directoryPath;
        _consoleOutput += "\nFolder aktif:\n$_selectedDirectory";
      });
    }
  }

  Future<void> _executeGit(List<String> args) async {
    if (_selectedDirectory == null) {
      setState(() => _consoleOutput = "Pilih folder project terlebih dahulu!");
      return;
    }
    
    if (args.contains('push') && (_savedRepoUrl.isEmpty || _savedToken.isEmpty)) {
      setState(() => _consoleOutput = "Gagal Push: Anda harus mengisi Link Repo dan Token di Pengaturan!");
      return;
    }
    
    setState(() => _consoleOutput = "Menjalankan git ${args.join(' ')}...\nMohon tunggu.");
    
    String result = await _gitService.runCommand(
      args, 
      _selectedDirectory!,
      repoUrl: _savedRepoUrl,
      token: _savedToken,
    );
    
    setState(() {
      _consoleOutput = result;
    });
  }

  void _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    
    if (result == true) {
      await _loadSettingsData();
    }
  }

  @override
  void dispose() {
    _commitController.dispose();
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
              Text("Menyiapkan Sistem Git...")
            ],
          ),
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digitmoba Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan Git',
            onPressed: _openSettings,
          )
        ],
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
                    style: TextStyle(
                      // Warna akan otomatis merah jika terjadi Error sistem
                      color: _consoleOutput.startsWith("GAGAL") ? Colors.redAccent : Colors.greenAccent, 
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