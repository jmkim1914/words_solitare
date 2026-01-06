import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level_model.dart';

class LevelLoader {
  // JSON 파일에서 레벨 데이터를 로드하는 함수
  static Future<LevelModel> loadLevel(int levelNumber) async {
    try {
      // 레벨 번호 3자리 포맷(ex: 1 -> 001)
      final levelFileName = 'level_${levelNumber.toString().padLeft(3, '0')}.json';
      
      // assets/levels/ 폴더에서 JSON 파일 읽기
      final String jsonString = await rootBundle.loadString('assets/data/levels/$levelFileName');

      // JSON 파싱
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // LevelModel 생성
      return LevelModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load level $levelNumber: $e');
    }
  }

  // 여러 레벨 한번에 로드
  static Future<List<LevelModel>> loadLevels(List<int> levelNumbers) async {
    final List<LevelModel> levels = [];

    for (final levelNumber in levelNumbers) {
      try {
        final level = await loadLevel(levelNumber);
        levels.add(level);
      } catch (e) {
        print('Error loading level $levelNumber: $e');
      }
    }
  }
}