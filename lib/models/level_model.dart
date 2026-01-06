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

  LevelCon
}

class LevelModel {
    final int level; // 레벨 번호
    final int deckCountMin;
    final int deckCountMax;
    final int keywordCountMin;
    final int keywordCountMax;
    final int relatedWordCountMin;
    final int relatedWordCountMax;

    LevelModel({
        required this.level,
        required this.deckCountMin,
        required this.deckCountMax,
        required this.keywordCountMin,
        required this.keywordCountMax,
        required this.relatedWordCountMin,
        required this.relatedWordCountMax,
    });

    int getRandomDeckCount() {
        if (deckCountMin == deckCountMax) {
            return deckCountMin;
        }
        return Random().nextInt(deckCountMax - deckCountMin + 1) + deckCountMin;
    }

    factory LevelModel.fromJson(Map<String, dynamic> json) {
        return LevelModel(
            level: json['level'],
            difficulty: json['difficulty'],
            deckCountMin: json['deck_count_min'],
            deckCountMax: json['deck_count_max'],
            wordGroups: (json['word_groups'] as List)
                .map((item) => WordGroup.fromJson(item))
                .toList()
        );
    }
}