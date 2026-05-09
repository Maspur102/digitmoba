import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GitService {
  String? _gitExecutablePath;

  Future<void> initGit() async {
    final dir = await getApplicationSupportDirectory();
    
    // Melompat keluar dari folder 'files' dan masuk ke folder 'lib' bawaan sistem Android
    final libDir = Directory('${dir.parent.path}/lib');

    if (await libDir.exists()) {
      // Mencari file libgit.so di dalam folder arsitektur native (arm64)
      await for (var entity in libDir.list(recursive: true)) {
        if (entity.path.endsWith('libgit.so')) {
          _gitExecutablePath = entity.path;
          break;
        }
      }
    }

    if (_gitExecutablePath == null) {
      throw Exception("Gagal! File libgit.so tidak ditemukan di sistem native Android. Pastikan folder jniLibs terbawa saat build APK.");
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
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception("WAKTU HABIS! Proses Git tidak merespon.");
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