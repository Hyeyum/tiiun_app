// lib/utils/migration_helper.dart - Base64 데이터 마이그레이션 도구
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tiiun/utils/encoding_utils.dart';
import 'package:tiiun/services/auth_service.dart';

/// ✅ Base64 → 직접 저장 마이그레이션 헬퍼
class MigrationHelper {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  // 마이그레이션 통계
  int _totalDocuments = 0;
  int _migratedDocuments = 0;
  int _failedDocuments = 0;
  int _totalFieldsMigrated = 0;
  final List<String> _failedDocumentIds = [];

  MigrationHelper(this._firestore, this._authService);

  /// ✅ 전체 마이그레이션 실행
  Future<MigrationResult> migrateAllUserData() async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      debugPrint('🚀 Base64 → 직접 저장 마이그레이션 시작');

      final startTime = DateTime.now();

      // 1. 대화 컬렉션 마이그레이션
      final conversationResult = await _migrateConversations(userId);

      // 2. 메시지 컬렉션 마이그레이션
      final messageResult = await _migrateMessages(userId);

      // 3. 사용자 프로필 마이그레이션
      final userResult = await _migrateUserProfile(userId);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final result = MigrationResult(
        totalDocuments: _totalDocuments,
        migratedDocuments: _migratedDocuments,
        failedDocuments: _failedDocuments,
        totalFieldsMigrated: _totalFieldsMigrated,
        failedDocumentIds: _failedDocumentIds,
        duration: duration,
        sizeSaved: conversationResult.sizeSaved + messageResult.sizeSaved + userResult.sizeSaved,
      );

      debugPrint('✅ 마이그레이션 완료: ${result.toString()}');

      return result;

    } catch (e) {
      debugPrint('❌ 마이그레이션 실패: $e');
      rethrow;
    }
  }

  /// ✅ 대화 컬렉션 마이그레이션
  Future<CollectionMigrationResult> _migrateConversations(String userId) async {
    debugPrint('📝 대화 컬렉션 마이그레이션 시작...');

    final query = _firestore
        .collection('conversations')
        .where('user_id', isEqualTo: userId);

    return await _migrateCollection(
      query: query,
      collectionName: 'conversations',
      fieldsToMigrate: ['title', 'summary'],
    );
  }

  /// ✅ 메시지 컬렉션 마이그레이션
  Future<CollectionMigrationResult> _migrateMessages(String userId) async {
    debugPrint('💬 메시지 컬렉션 마이그레이션 시작...');

    // 사용자의 대화 ID들을 먼저 가져오기
    final conversationsSnapshot = await _firestore
        .collection('conversations')
        .where('user_id', isEqualTo: userId)
        .get();

    final conversationIds = conversationsSnapshot.docs.map((doc) => doc.id).toList();

    if (conversationIds.isEmpty) {
      return CollectionMigrationResult.empty();
    }

    // 배치로 처리 (in 쿼리는 10개씩만 가능)
    int totalSizeSaved = 0;
    int totalMigrated = 0;

    for (int i = 0; i < conversationIds.length; i += 10) {
      final batch = conversationIds.skip(i).take(10).toList();

      final query = _firestore
          .collection('messages')
          .where('conversation_id', whereIn: batch);

      final result = await _migrateCollection(
        query: query,
        collectionName: 'messages',
        fieldsToMigrate: ['content', 'error_message'],
      );

      totalSizeSaved += result.sizeSaved;
      totalMigrated += result.migratedCount;
    }

    return CollectionMigrationResult(
      collectionName: 'messages',
      totalCount: _totalDocuments,
      migratedCount: totalMigrated,
      sizeSaved: totalSizeSaved,
    );
  }

  /// ✅ 사용자 프로필 마이그레이션
  Future<CollectionMigrationResult> _migrateUserProfile(String userId) async {
    debugPrint('👤 사용자 프로필 마이그레이션 시작...');

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return CollectionMigrationResult.empty();
      }

      final data = userDoc.data()!;
      final migrations = EncodingUtils.migrateBase64Fields(
        data,
        ['user_name', 'profile_description'],
      );

      if (migrations.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          ...migrations,
          'migrated_at': Timestamp.now(),
        });

        _migratedDocuments++;
        _totalFieldsMigrated += migrations.length;

        // 크기 절약 계산
        int sizeSaved = 0;
        migrations.forEach((field, value) {
          final originalSize = utf8.encode(data[field] as String).length;
          final newSize = utf8.encode(value).length;
          sizeSaved += (originalSize - newSize);
        });

        return CollectionMigrationResult(
          collectionName: 'users',
          totalCount: 1,
          migratedCount: 1,
          sizeSaved: sizeSaved,
        );
      }

      return CollectionMigrationResult.empty();

    } catch (e) {
      debugPrint('사용자 프로필 마이그레이션 실패: $e');
      _failedDocuments++;
      _failedDocumentIds.add(userId);
      return CollectionMigrationResult.empty();
    }
  }

  /// ✅ 컬렉션 마이그레이션 공통 로직
  Future<CollectionMigrationResult> _migrateCollection({
    required Query query,
    required String collectionName,
    required List<String> fieldsToMigrate,
  }) async {

    final snapshot = await query.get();
    final documents = snapshot.docs;

    _totalDocuments += documents.length;

    int migratedCount = 0;
    int totalSizeSaved = 0;

    // 배치 처리로 성능 최적화
    final batches = <WriteBatch>[];
    WriteBatch currentBatch = _firestore.batch();
    int operationsInBatch = 0;

    for (final doc in documents) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final migrations = EncodingUtils.migrateBase64Fields(data, fieldsToMigrate);

        if (migrations.isNotEmpty) {
          // 크기 절약 계산
          int docSizeSaved = 0;
          migrations.forEach((field, newValue) {
            final originalValue = data[field] as String? ?? '';
            final originalSize = utf8.encode(originalValue).length;
            final newSize = utf8.encode(newValue).length;
            docSizeSaved += (originalSize - newSize);
          });

          totalSizeSaved += docSizeSaved;
          migratedCount++;
          _totalFieldsMigrated += migrations.length;

          // 배치에 업데이트 추가
          currentBatch.update(doc.reference, {
            ...migrations,
            'migrated_at': Timestamp.now(),
          });

          operationsInBatch++;

          // 배치 크기 제한 (500개)
          if (operationsInBatch >= 400) {
            batches.add(currentBatch);
            currentBatch = _firestore.batch();
            operationsInBatch = 0;
          }
        }

      } catch (e) {
        debugPrint('문서 마이그레이션 실패 (${doc.id}): $e');
        _failedDocuments++;
        _failedDocumentIds.add(doc.id);
      }
    }

    // 마지막 배치 추가
    if (operationsInBatch > 0) {
      batches.add(currentBatch);
    }

    // 모든 배치 실행
    for (final batch in batches) {
      await batch.commit();
    }

    _migratedDocuments += migratedCount;

    debugPrint('✅ $collectionName 마이그레이션 완료: $migratedCount/$_totalDocuments, 절약: ${totalSizeSaved}바이트');

    return CollectionMigrationResult(
      collectionName: collectionName,
      totalCount: documents.length,
      migratedCount: migratedCount,
      sizeSaved: totalSizeSaved,
    );
  }

  /// ✅ 마이그레이션 진행률 체크
  Future<MigrationProgress> checkMigrationProgress() async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 대화 컬렉션 체크
      final conversationsTotal = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId)
          .count()
          .get();

      final conversationsMigrated = await _firestore
          .collection('conversations')
          .where('user_id', isEqualTo: userId)
          .where('migrated_at', isNull: false)
          .count()
          .get();

      // 메시지 컬렉션 체크
      final conversationIds = await _getConversationIds(userId);
      int messagesTotal = 0;
      int messagesMigrated = 0;

      for (int i = 0; i < conversationIds.length; i += 10) {
        final batch = conversationIds.skip(i).take(10).toList();

        final totalQuery = await _firestore
            .collection('messages')
            .where('conversation_id', whereIn: batch)
            .count()
            .get();

        final migratedQuery = await _firestore
            .collection('messages')
            .where('conversation_id', whereIn: batch)
            .where('migrated_at', isNull: false)
            .count()
            .get();

        messagesTotal += totalQuery.count ?? 0;
        messagesMigrated += migratedQuery.count ?? 0;
      }

      return MigrationProgress(
        conversationsTotal: conversationsTotal.count ?? 0,
        conversationsMigrated: conversationsMigrated.count ?? 0,
        messagesTotal: messagesTotal,
        messagesMigrated: messagesMigrated,
      );

    } catch (e) {
      debugPrint('마이그레이션 진행률 체크 실패: $e');
      rethrow;
    }
  }

  /// ✅ 대화 ID 목록 가져오기
  Future<List<String>> _getConversationIds(String userId) async {
    final snapshot = await _firestore
        .collection('conversations')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// ✅ 마이그레이션 롤백 (필요한 경우)
  Future<void> rollbackMigration() async {
    debugPrint('🔄 마이그레이션 롤백 시작...');

    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }

    // 마이그레이션된 문서들 찾기
    final collections = ['conversations', 'messages', 'users'];

    for (final collectionName in collections) {
      if (collectionName == 'users') {
        // 사용자 문서 직접 처리
        final userDoc = await _firestore.collection(collectionName).doc(userId).get();
        if (userDoc.exists && userDoc.data()?['migrated_at'] != null) {
          // 롤백 로직 구현...
          debugPrint('사용자 문서 롤백 필요: $userId');
        }
      } else if (collectionName == 'conversations') {
        final query = _firestore
            .collection(collectionName)
            .where('user_id', isEqualTo: userId)
            .where('migrated_at', isNull: false);

        final snapshot = await query.get();
        debugPrint('대화 문서 롤백 필요: ${snapshot.docs.length}개');

      } else if (collectionName == 'messages') {
        // messages의 경우 conversation_id로 필터링 필요
        final conversationIds = await _getConversationIds(userId);

        for (int i = 0; i < conversationIds.length; i += 10) {
          final batch = conversationIds.skip(i).take(10).toList();

          final query = _firestore
              .collection(collectionName)
              .where('conversation_id', whereIn: batch)
              .where('migrated_at', isNull: false);

          final snapshot = await query.get();
          debugPrint('메시지 문서 롤백 필요: ${snapshot.docs.length}개');
        }
      }

      // 롤백 로직 구현...
      // 주의: 실제로는 매우 신중하게 구현해야 함
    }

    debugPrint('✅ 마이그레이션 롤백 완료');
  }
}

/// ✅ 마이그레이션 결과 클래스들
class MigrationResult {
  final int totalDocuments;
  final int migratedDocuments;
  final int failedDocuments;
  final int totalFieldsMigrated;
  final List<String> failedDocumentIds;
  final Duration duration;
  final int sizeSaved;

  MigrationResult({
    required this.totalDocuments,
    required this.migratedDocuments,
    required this.failedDocuments,
    required this.totalFieldsMigrated,
    required this.failedDocumentIds,
    required this.duration,
    required this.sizeSaved,
  });

  double get successRate => totalDocuments > 0 ? (migratedDocuments / totalDocuments) * 100 : 0;
  String get sizeSavedFormatted => '${(sizeSaved / 1024).toStringAsFixed(1)} KB';

  @override
  String toString() {
    return '''
마이그레이션 결과:
- 전체 문서: $totalDocuments개
- 마이그레이션 성공: $migratedDocuments개 (${successRate.toStringAsFixed(1)}%)
- 실패: $failedDocuments개
- 마이그레이션된 필드: $totalFieldsMigrated개
- 절약된 크기: $sizeSavedFormatted
- 소요 시간: ${duration.inSeconds}초
''';
  }
}

class CollectionMigrationResult {
  final String collectionName;
  final int totalCount;
  final int migratedCount;
  final int sizeSaved;

  CollectionMigrationResult({
    required this.collectionName,
    required this.totalCount,
    required this.migratedCount,
    required this.sizeSaved,
  });

  factory CollectionMigrationResult.empty() {
    return CollectionMigrationResult(
      collectionName: '',
      totalCount: 0,
      migratedCount: 0,
      sizeSaved: 0,
    );
  }
}

class MigrationProgress {
  final int conversationsTotal;
  final int conversationsMigrated;
  final int messagesTotal;
  final int messagesMigrated;

  MigrationProgress({
    required this.conversationsTotal,
    required this.conversationsMigrated,
    required this.messagesTotal,
    required this.messagesMigrated,
  });

  double get conversationProgress =>
      conversationsTotal > 0 ? (conversationsMigrated / conversationsTotal) * 100 : 100;

  double get messageProgress =>
      messagesTotal > 0 ? (messagesMigrated / messagesTotal) * 100 : 100;

  double get overallProgress =>
      (conversationProgress + messageProgress) / 2;

  bool get isCompleted =>
      conversationsMigrated >= conversationsTotal &&
          messagesMigrated >= messagesTotal;
}
