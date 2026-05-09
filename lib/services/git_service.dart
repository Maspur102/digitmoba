import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class GitService {
  String? _gitExecutablePath;

  Future<void> initGit() async {
    final directory = await getApplicationSupportDirectory();
    _gitExecutablePath = '${directory.path}/git';
    final file = File(_gitExecutablePath!);
    
    if (!await file.exists() || await file.length() < 1000) { 
      try {
        ByteData data = await rootBundle.load('assets/bin/git');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await file.writeAsBytes(bytes);
        await Process.run('chmod', ['755', _gitExecutablePath!]);
      } catch (e) {
        throw Exception("Gagal ekstrak Git: $e");
      }
    }
  }

  Future<String> runCommand(List<String> args, String workingDirectory, {String? repoUrl, String? token}) async {
    if (_gitExecutablePath == null) return "Error: Git belum diinisialisasi.";

    if (!await Directory(workingDirectory).exists()) {
      return "Error: Folder project tidak ditemukan. Pastikan izin File Aktif.";
    }

    if (token != null && token.isNotEmpty && repoUrl != null && repoUrl.isNotEmpty) {
       if (args.contains('push') || args.contains('pull')) {
         
         String authUrl = repoUrl;
         if (authUrl.startsWith('https://')) {
             authUrl = authUrl.replaceFirst('https://', 'https://$token@');
         }

         await Process.run(
           _gitExecutablePath!,
           ['remote', 'set-url', 'origin', authUrl],
           workingDirectory: workingDirectory,
         );
       }
    }

    try {
      ProcessResult result = await Process.run(
        _gitExecutablePath!,
        args,
        workingDirectory: workingDirectory,
        environment: {
          'GIT_TERMINAL_PROMPT': '0', 
          'HOME': workingDirectory,   
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("WAKTU HABIS (10 Detik)! Proses nyangkut. Pastikan Git sudah diinisialisasi akunnya, atau ganti binary git.");
      });

      if (result.exitCode == 0) {
        return result.stdout.toString().trim().isEmpty ? "Perintah sukses dijalankan." : result.stdout.toString();
      } else {
        return 'Error Git:\n${result.stderr}';
      }
    } catch (e) {
      return 'Sistem Gagal:\n$e';
    }
  }
}