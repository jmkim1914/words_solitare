import 'package:words_solitair/models/level_model.dart';

class DeckModel {
  String? keyword; // null이면 빈 덱
  List<String> matchedWords; // 맞춘 단어들
  List<String> requiredWords; // 덱에 필요한 단어들
  final int deckIndex; // 덱 인덱스

  DeckModel({
    this.keyword,
    this.matchedWords = const [],
    this.requiredWords = const [],
    required this.deckIndex,
  });

  // 덱이 완성되었는지 여부
  bool get isEmpty => keyword == null;

  // 덱이 완성되었는지 여부
  bool get isComplete => !isEmpty && matchedWords.length >= requiredWords.length;

  // 덱의 진행률
  double get progress {
    if (isEmpty || requiredWords.isEmpty) return 0.0;
    return matchedWords.length / requiredWords.length;
  }

  // 단어카드 accept 가능 여부
  bool canAcceptWord(String word, LevelModel level) {
    if (isEmpty) {
      // 빈 덱은 키워드 카드만 받음
      return level.wordGroups.any((group) => group.getKeyword() == word);
    } else {
      // 키워드가 있으면 해당 그룹의 단어만 받음
      final group = level.wordGroups.firstWhere(
          (g) => g.getKeyword() == keyword,
          orElse: () => throw Exception('Invalid deck keyword'));
      
      // 그룹에 속한 단어이면서 아직 맞추지 않은 단어여야 함
      return group.getRelatedWords().contains(word) && !matchedWords.contains(word);
    }
  }

  DeckModel acceptWord(String word, LevelModel level) {
    if (!canAcceptWord(word, level)) {
      throw Exception('Cannot accept word: $word');
    }    

    if (isEmpty) {
      final group = level.wordGroups.firstWhere(
          (g) => g.getKeyword() == word);

      // 빈 덱이면 키워드 카드 수락
      return DeckModel(
        keyword: word,
        matchedWords: [],
        requiredWords: group.getRelatedWords(),
        deckIndex: deckIndex,
      );
    } else {
      // 이미 키워드가 있으면 단어 추가
      return DeckModel(
        keyword: keyword,
        matchedWords: [...matchedWords, word],
        requiredWords: requiredWords,
        deckIndex: deckIndex,
      );
    }
  }

  DeckModel copyWith({
    String? keyword,
    List<String>? matchedWords,
    List<String>? requiredWords
  }) {
    return DeckModel(
      keyword: keyword ?? this.keyword,
      matchedWords: matchedWords ?? this.matchedWords,
      requiredWords: requiredWords ?? this.requiredWords,
      deckIndex: this.deckIndex,
    );
  }
}