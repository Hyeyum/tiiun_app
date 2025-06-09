// import 'package:flutter/material.dart';
// import '../services/api_client.dart';
// import '../services/shopping_item_api_service.dart';
// import '../services/plant_api_service.dart';
// import '../services/favorite_api_service.dart';
// import '../utils/logger.dart';

// class ApiTestPage extends StatefulWidget {
//   const ApiTestPage({super.key});

//   @override
//   State<ApiTestPage> createState() => _ApiTestPageState();
// }

// class _ApiTestPageState extends State<ApiTestPage> {
//   final _results = <String>[];
//   bool _isLoading = false;

//   void _addResult(String result) {
//     setState(() {
//       _results.add(result);
//     });
//   }

//   void _clearResults() {
//     setState(() {
//       _results.clear();
//     });
//   }

//   Future<void> _testShoppingItems() async {
//     setState(() => _isLoading = true);
//     try {
//       _addResult('🛒 쇼핑 아이템 API 테스트 시작...');

//       final service = ShoppingItemApiService();
//       final response = await service.getAllShoppingItems();

//       if (response.isSuccess) {
//         _addResult('✅ 쇼핑 아이템 조회 성공: ${response.data?.length}개 아이템');
//         if (response.data?.isNotEmpty == true) {
//           final firstItem = response.data!.first;
//           _addResult('   첫 번째 아이템: ${firstItem.name}');
//         }
//       } else {
//         _addResult('❌ 쇼핑 아이템 조회 실패: ${response.error}');
//       }
//     } catch (e) {
//       _addResult('❌ 쇼핑 아이템 API 오류: $e');
//       AppLogger.error('Shopping items test error: $e');
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _testPlants() async {
//     setState(() => _isLoading = true);
//     try {
//       _addResult('🌱 식물 API 테스트 시작...');

//       final service = PlantApiService();
//       final response = await service.getMyPlants();

//       if (response.isSuccess) {
//         _addResult('✅ 내 식물 조회 성공: ${response.data?.length}개 식물');
//         if (response.data?.isNotEmpty == true) {
//           final firstPlant = response.data!.first;
//           _addResult('   첫 번째 식물: ${firstPlant.nickname ?? firstPlant.speciesName}');
//         }
//       } else {
//         _addResult('❌ 식물 조회 실패: ${response.error}');
//       }
//     } catch (e) {
//       _addResult('❌ 식물 API 오류: $e');
//       AppLogger.error('Plants test error: $e');
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _testFavorites() async {
//     setState(() => _isLoading = true);
//     try {
//       _addResult('⭐ 즐겨찾기 API 테스트 시작...');

//       final service = FavoriteApiService();
//       final response = await service.getMyFavorites();

//       if (response.isSuccess) {
//         _addResult('✅ 즐겨찾기 조회 성공: ${response.data?.length}개 아이템');
//       } else {
//         _addResult('❌ 즐겨찾기 조회 실패: ${response.error}');
//       }
//     } catch (e) {
//       _addResult('❌ 즐겨찾기 API 오류: $e');
//       AppLogger.error('Favorites test error: $e');
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _testServerConnection() async {
//     setState(() => _isLoading = true);
//     try {
//       _addResult('🔌 서버 연결 테스트 시작...');

//       final apiClient = ApiClient();
//       final response = await apiClient.get('/shopping-items');

//       if (response.isSuccess) {
//         _addResult('✅ 서버 연결 성공 - 백엔드가 정상 작동 중입니다');
//       } else {
//         _addResult('❌ 서버 연결 실패: ${response.error}');
//       }
//     } catch (e) {
//       _addResult('❌ 서버 연결 오류: $e');
//       AppLogger.error('Server connection test error: $e');
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _runAllTests() async {
//     _clearResults();
//     _addResult('🚀 전체 API 테스트 시작...\n');

//     await _testServerConnection();
//     await Future.delayed(const Duration(milliseconds: 500));

//     await _testShoppingItems();
//     await Future.delayed(const Duration(milliseconds: 500));

//     await _testPlants();
//     await Future.delayed(const Duration(milliseconds: 500));

//     await _testFavorites();

//     _addResult('\n✨ 전체 테스트 완료!');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('API 테스트'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const Text(
//                   '백엔드 API 연결 테스트',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 8,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _runAllTests,
//                       child: const Text('전체 테스트'),
//                     ),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _testServerConnection,
//                       child: const Text('서버 연결'),
//                     ),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _testShoppingItems,
//                       child: const Text('쇼핑'),
//                     ),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _testPlants,
//                       child: const Text('식물'),
//                     ),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _testFavorites,
//                       child: const Text('즐겨찾기'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _clearResults,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey,
//                       ),
//                       child: const Text('결과 지우기'),
//                     ),
//                     if (_isLoading)
//                       const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),
//           Expanded(
//             child: _results.isEmpty
//                 ? const Center(
//                     child: Text(
//                       '테스트 버튼을 눌러 API 연결을 확인하세요',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _results.length,
//                     itemBuilder: (context, index) {
//                       final result = _results[index];
//                       Color textColor = Colors.black;

//                       if (result.startsWith('✅')) {
//                         textColor = Colors.green;
//                       } else if (result.startsWith('❌')) {
//                         textColor = Colors.red;
//                       } else if (result.startsWith('🚀') || result.startsWith('✨')) {
//                         textColor = Colors.blue;
//                       }

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 2),
//                         child: Text(
//                           result,
//                           style: TextStyle(
//                             color: textColor,
//                             fontFamily: 'monospace',
//                             fontSize: 13,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
