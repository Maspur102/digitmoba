import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class GitService {
  String? _gitExecutablePath;

  Future<void> initGit() async {
    final directory = await getApplicationSupportDirectory();
    _gitExecutablePath = '${directory.path}/git';
    final file = File(_gitExecutablePath!);
    
    // Ekstrak binary git jika belum ada di sistem internal
    if (!await file.exists()) {
      try {
        ByteData data = await rootBundle.load('assets/bin/git');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await file.writeAsBytes(bytes);
        // Beri izin eksekusi agar file bisa dijalankan seperti program
        await Process.run('chmod', ['755', _gitExecutablePath!]);
      } catch (e) {
        print("Gagal mengekstrak Git: $e");
      }
    }
  }

  Future<String> runCommand(List<String> args, String workingDirectory, {String? token, String? username}) async {
    if (_gitExecutablePath == null) return "Git belum diinisialisasi.";

    // Jika sedang melakukan push/pull dan ada token, kita bypass otentikasi via URL
    if (token != null && token.isNotEmpty && username != null && username.isNotEmpty) {
       if (args.contains('push') || args.contains('pull')) {
         await Process.run(
           _gitExecutablePath!,
           ['remote', 'set-url', 'origin', 'https://$token@github.com/$username/digitmoba.git'],
           workingDirectory: workingDirectory,
         );
       }
    }

    try {
      ProcessResult result = await Process.run(
        _gitExecutablePath!,
        args,
        workingDirectory: workingDirectory,
        environment: {'GIT_TERMINAL_PROMPT': '0'}, // Mencegah git meminta input interaktif
      );

      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        return 'Error:\n${result.stderr}';
      }
    } catch (e) {
      return 'Eksekusi gagal: $e';
    }
  }
}