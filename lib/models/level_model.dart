import 'dart:math';

class LocalizedText {
    final Map<String, String> translations; // 번역된 텍스트 맵

    LocalizedText({
        required this.translations
    });

    String getText(String locale) {
        return translations[locale] ?? translations['ko'] ?? '';
    }

    String get ko => getText('ko');

    factory LocalizedText.fromJson(Map<String, dynamic> json) {
        return LocalizedText(
            translations: Map<String, String>.from(json)
        );
    }
}

class WordGroup {
    final LocalizedText keyword; // 키워드
    final List<LocalizedText> related; // 관련 단어 목록

    WordGroup({
        required this.keyword, 
        required this.related
    });

    String getKeyword([String locale = 'ko']) {
        return keyword.getText(locale);
    }

    List<String> getRelatedWords([String locale = 'ko']) {
        return related.map((word) => word.getText(locale)).toList();
    }

    factory WordGroup.fromJson(Map<String, dynamic> json) {
        return WordGroup(
            keyword: LocalizedText.fromJson(json['keyword']),
            related: (json['related'] as List)
                .map((item) => LocalizedText.fromJson(item))
                .toList()
        );
    }
}

class WordPool {
  final List<WordGroup> wordGroups;

  WordPool({required this.wordGroups});

  // 랜덤으로 N개의 단어 그룹 선택
  List<WordGroup> getRandomWordGroups(int count) {
    if (count > wordGroups.length) {
      throw Exception('Not enough word groups. Need $count, have ${wordGroups.length}');
    }

    final shuffled = List<WordGroup>.from(wordGroups)..shuffle();
    return shuffled.sublist(0, count);
  }

  factory WordPool.fromJson(Map<String, dynamic> json) {
    return WordPool(
      wordGroups: (json['word_groups'] as List)
          .map((item) => WordGroup.fromJson(item))
          .toList(),
    );
  }
}

class LevelConfig {
  final int level;
  final int deckCountMin;
  final int deckCountMax;
  final int keywordCountMin;
  final int keywordCountMax;
  final int relatedWordCountMin;
  final int relatedWordCountMax;

  LevelConfig({
    required this.level,
    required this.deckCountMin,
    required this.deckCountMax,
    required this.keywordCountMin,
    required this.keywordCountMax,
    required this.relatedWordCountMin,
    required this.relatedWordCountMax,
  });

  String get difficulty {
    if (level <= 100) return 'Easy';
    if (level <= 200) return 'Medium';
    return 'Hard';
  }

  // 랜덤 덱 개수
  int getRandomDeckCount() {
    if (deckCountMin == deckCountMax) {
      return deckCountMin;
    }
    return Random().nextInt(deckCountMax - deckCountMin + 1) + deckCountMin;
  }

  // 랜덤 키워드 개수
  int getRandomKeywordCount() {
    if (keywordCountMin == keywordCountMax) {
      return keywordCountMin;
    }
    return Random().nextInt(keywordCountMax - keywordCountMin + 1) + keywordCountMin;
  }

  // 랜덤 관련 단어 개수
  int getRandomRelatedWordCount() {
    if (relatedWordCountMin == relatedWordCountMax) {
      return relatedWordCountMin;
    }
    return Random().nextInt(relatedWordCountMax - relatedWordCountMin + 1) + relatedWordCountMin;
  }

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      level: json['level'],
      deckCountMin: json['deck_count_min'],
      deckCountMax: json['deck_count_max'],
      keywordCountMin: json['keyword_count_min'],
      keywordCountMax: json['keyword_count_max'],
      relatedWordCountMin: json['related_word_count_min'],
      relatedWordCountMax: json['related_word_count_max'],
    );
  }
}

class LevelModel {
    final int level;
    final String difficulty;
    final int deckCountMin;
    final int deckCountMax;
    final List<WordGroup> wordGroups;

    LevelModel({
        required this.level,
        required this.difficulty,
        required this.deckCountMin,
        required this.deckCountMax,
        required this.wordGroups
    });

    int getRandomDeckCount() {
        if (deckCountMin == deckCountMax) {
            return deckCountMin;
        }
        return Random().nextInt(deckCountMax - deckCountMin + 1) + deckCountMin;
    }
}