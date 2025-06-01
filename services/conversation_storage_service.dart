// lib/services/conversation_storage_service_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/export_format.dart';

/// 내보내기 파일 저장
Future<String?> _saveExportToFile(
  String content,
  String fileName,
  ExportFormat format,
  String? customPath
) async {
  try {
    // 파일 확장자 결정
    String extension;
    switch (format) {
      case ExportFormat.json:
        extension = 'json';
        break;
      case ExportFormat.markdown:
        extension = 'md';
        break;
      case ExportFormat.text:
        extension = 'txt';
        break;
      case ExportFormat.html:
        extension = 'html';
        break;
      case ExportFormat.csv:
        extension = 'csv';
        break;
      case ExportFormat.pdf:
        extension = 'pdf';
        break;
      default:
        extension = 'txt';
    }

    // 파일명에 특수문자 제거
    final sanitizedFileName = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');

    // 최종 파일명
    final finalFileName = '${sanitizedFileName}.$extension';

    // 저장 경로 결정
    late final String filePath;

    if (customPath != null && customPath.isNotEmpty) {
      // 사용자 지정 경로 사용
      final directory = Directory(customPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      filePath = '${directory.path}/$finalFileName';
    } else {
      // 기본 경로 (외부 저장소)
      Directory? directory;

      if (Platform.isAndroid) {
        // Android의 경우 다운로드 디렉토리 사용
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        directory = Directory('/storage/emulated/0/Download/MentalHealth');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        // iOS 또는 기타 플랫폼의 경우 문서 디렉토리 사용
        directory = await getApplicationDocumentsDirectory();
        final mentalHealthDir = Directory('${directory.path}/MentalHealth');
        if (!await mentalHealthDir.exists()) {
          await mentalHealthDir.create(recursive: true);
        }
        directory = mentalHealthDir;
      }

      filePath = '${directory.path}/$finalFileName';
    }

    // 파일 저장
    final file = File(filePath);
    await file.writeAsString(content, flush: true);

    debugPrint('파일 저장 완료: $filePath');
    return filePath;
  } catch (e) {
    debugPrint('파일 저장 오류: $e');
    return null;
  }
}