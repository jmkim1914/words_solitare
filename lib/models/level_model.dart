import 'dart:math';

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

class LevelModel {
    final int level; // 레벨 번호
    final String difficulty; // 난이도
    final int deckCountMin;
    final int deckCountMax;
    final List<WordGroup> wordGroups; // 단어 그룹 목록

    LevelModel({
        required this.level, 
        required this.wordGroups,
        required this.difficulty, 
        required this.deckCountMin,
        required this.deckCountMax
    });

    int getRandomDeckCount() {
        if (deckCountMin == deckCountMax) {
            return deckCountMin;
        }
        return Random().nextInt(deckCountMax - deckCountMin + 1) + deckCountMin;
    }
}

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