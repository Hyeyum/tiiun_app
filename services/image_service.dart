// lib/services/image_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  /// 권한 확인 및 요청
  Future<bool> _checkPermissions(ImageSource source) async {
    Permission permission = source == ImageSource.camera 
        ? Permission.camera 
        : Permission.photos;

    PermissionStatus status = await permission.status;
    
    if (status.isDenied) {
      status = await permission.request();
    }
    
    return status.isGranted;
  }

  /// 이미지 선택 (카메라 또는 갤러리)
  Future<File?> pickImage({
    required ImageSource source,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // 권한 확인
      bool hasPermission = await _checkPermissions(source);
      if (!hasPermission) {
        throw Exception('${source == ImageSource.camera ? "카메라" : "갤러리"} 권한이 필요합니다.');
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality ?? 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
      rethrow;
    }
  }

  /// Firebase Storage에 이미지 업로드
  Future<String> uploadImage({
    required File imageFile,
    required String conversationId,
  }) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 고유한 파일명 생성
      String fileName = '${_uuid.v4()}.jpg';
      
      // Storage 경로 설정: images/{userId}/{conversationId}/{fileName}
      String path = 'images/$userId/$conversationId/$fileName';
      
      // Firebase Storage 레퍼런스 생성
      Reference ref = _storage.ref().child(path);
      
      // 이미지 업로드
      UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'conversationId': conversationId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // 업로드 완료 대기
      TaskSnapshot snapshot = await uploadTask;
      
      // 다운로드 URL 가져오기
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('이미지 업로드 성공: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      debugPrint('이미지 업로드 오류: $e');
      throw Exception('이미지 업로드에 실패했습니다: ${e.toString()}');
    }
  }

  /// 이미지 선택부터 업로드까지 한번에 처리
  Future<String?> pickAndUploadImage({
    required ImageSource source,
    required String conversationId,
    BuildContext? context,
  }) async {
    try {
      // 1. 이미지 선택
      File? imageFile = await pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (imageFile == null) {
        return null; // 사용자가 취소함
      }

      // 2. 이미지 업로드
      String downloadUrl = await uploadImage(
        imageFile: imageFile,
        conversationId: conversationId,
      );

      return downloadUrl;
      
    } catch (e) {
      debugPrint('이미지 처리 오류: $e');
      if (context != null) {
        _showErrorSnackBar(context, e.toString());
      }
      return null;
    }
  }

  /// 이미지 소스 선택 다이얼로그 표시
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이미지 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  /// 이미지 삭제 (필요시)
  Future<bool> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('이미지 삭제 성공: $imageUrl');
      return true;
    } catch (e) {
      debugPrint('이미지 삭제 오류: $e');
      return false;
    }
  }

  /// 에러 스낵바 표시
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
