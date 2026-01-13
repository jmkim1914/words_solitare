import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/level_model.dart';

class LevelLoader {
  static WordPool? _wordPool;

  // 단어 풀 로드 (캐싱)
  static Future<WordPool> loadWordPool() async {
    if (_wordPool != null) return _wordPool!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/word_groups.json'
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _wordPool = WordPool.fromJson(jsonData);
      
      return _wordPool!;
    } catch (e) {
      throw Exception('Failed to load word pool: $e');
    }
  }

  // 레벨 설정 로드
  static Future<LevelConfig> loadLevelConfig(int levelNumber) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/levels_config.json'
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final levels = jsonData['levels'] as List;
      
      final levelData = levels.firstWhere(
        (l) => l['level'] == levelNumber,
        orElse: () => throw Exception('Level $levelNumber not found'),
      );
      
      return LevelConfig.fromJson(levelData);
    } catch (e) {
      throw Exception('Failed to load level config $levelNumber: $e');
    }
  }

  // 레벨 생성 (완전 랜덤화!)
  static Future<LevelModel> generateLevel(int levelNumber) async {
    final wordPool = await loadWordPool();
    final config = await loadLevelConfig(levelNumber);
    
    // 1. 랜덤 값 결정
    final deckCount = config.getRandomDeckCount();
    final keywordCount = config.getRandomKeywordCount();
    
    // 2. 랜덤 단어 그룹 선택
    var selectedGroups = wordPool.getRandomWordGroups(keywordCount);
    
    // 3. 각 그룹의 연관 단어를 랜덤 개수만큼 자르기
    selectedGroups = selectedGroups.map((group) {
      final wordCount = config.getRandomRelatedWordCount();
      
      // 10개 중에서 필요한 개수만큼만 사용
      final shuffledRelated = List<LocalizedText>.from(group.related)..shuffle();
      final trimmedRelated = shuffledRelated.take(wordCount).toList();
      
      return WordGroup(
        keyword: group.keyword,
        related: trimmedRelated,
      );
    }).toList();
    
    // 4. LevelModel 생성
    return LevelModel(
      level: config.level,
      difficulty: config.difficulty,
      deckCountMin: deckCount,
      deckCountMax: deckCount,
      wordGroups: selectedGroups,
    );
  }
}