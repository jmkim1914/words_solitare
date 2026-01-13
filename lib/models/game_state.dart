import 'deck_model.dart';
import 'level_model.dart';

class GameState {
  final LevelModel levelModel;
  final List<DeckModel> decks;
  final List<String> availableWords; // 하단 카드 영역의 단어들
  final Set<String> completedKeywords // 완성된 키워드
  final int coins; // 게임머니
  final bool isCompleted; // 게임 완료 여부

  GameState({
    required this.levelModel,
    required this.decks,
    required this.availableWords,
    required this.completedKeywords,
    required this.coins,
    this.isCompleted = false,
  });

  // 초기 게임 상태 생성
  factory GameState.initial(LevelModel levelModel, int coins) {
    final deckCount = levelModel.getRandomDeckCount();

    final decks = List.generate(
      deckCount,
      (index) => DeckModel(deckIndex: index),
    );

    final allWords = <String>[];
    for (var group in levelModel.wordGroups) {
      allWords.add(group.getKeyword());
      allWords.addAll(group.getRelatedWords());
    }
    allWords.shuffle();

    return GameState(
      levelModel: levelModel,
      decks: decks,
      availableWords: allWords,
      completedKeywords: {},
      coins: 0,
    );
  }

  // 게임 완료 조건: 모든 덱이 완성되었는지 확인
  bool get isGameCompleted => completedKeywords.length == levelModel.wordGroups.length;

  // 단어를 덱에 배치하는 함수
  GameState placeWordInDeck(String word, int deckIndex) {
    final deck = decks[deckIndex];

    if (!deck.canAcceptWord(word, levelModel)) {
      return this;
    }

    // 덱에 단어 배치 가능 시.. 
    final newDecks = List<DeckModel>.from(decks);
    newDecks[deckIndex] = deck.acceptWord(word, levelModel);

    final newAvailableWords = List<String>.from(availableWords);
    newAvailableWords.remove(word);

    var newState = copyWith(
      decks: newDecks,
      availableWords: newAvailableWords,
    );

    // 모든 덱이 완성되었는지 확인
    if (newDecks[deckIndex].isComplete) {
      newState = newState.clearCompletedDecks(deckIndex);
    }

    return newState;
  }

  // 완성된 덱 비우기
  GameState clearCompletedDecks(int deckIndex) {
     final completedKeyword = decks[deckIndex].keyword!;
    
    // 새로운 덱 리스트 생성 (해당 덱만 비우기)
    final newDecks = List<DeckModel>.from(decks);
    newDecks[deckIndex] = DeckModel(deckIndex: deckIndex);
    
    // 완성한 키워드 기록
    final newCompletedKeywords = Set<String>.from(completedKeywords);
    newCompletedKeywords.add(completedKeyword);
    
    // 게임 완료 여부 체크
    final gameComplete = newCompletedKeywords.length == levelModel.wordGroups.length;
    
    return copyWith(
      decks: newDecks,
      completedKeywords: newCompletedKeywords,
      isCompleted: gameComplete,
    );
  }

  // 힌트 사용(100코인)
  GameState useHint() {
    if (coins < 100) {
      return this;
    }

    // 완성되지 않은 덱 중에서 무작위로 하나 선택
    final incompleteDecks = decks.where((d) => !d.isComplete).toList();
    if (incompleteDecks.isEmpty) {
      throw Exception('All decks are already complete');
    }

    final deck = (incompleteDecks..shuffle()).first;
    final deckIndex = deck.deckIndex;

    // 덱에 필요한 단어 중 아직 맞추지 않은 단어들 중에서 무작위로 하나 선택
    final group = levelModel.wordGroups.firstWhere(
        (g) => g.getKeyword() == deck.keyword);
    final remainingWords = group.getRelatedWords()
        .where((word) => !deck.matchedWords.contains(word))
        .toList();

    if (remainingWords.isEmpty) {
      throw Exception('No remaining words to hint for this deck');
    }

    final hintedWord = (remainingWords..shuffle()).first;

    // 단어를 덱에 배치
    return placeWordInDeck(hintedWord, deckIndex)
        .copyWith(coins: coins - 100);
  }

  // 뒤로가기 사용 (50코인)
  GameState useUndo() {
    if (coins < 50) {
      return this;
    }

    // TODO: Implement undo logic
    return copyWith(coins: coins - 50);
  }

  // 셔플 사용 (30코인)
  GameState useShuffle() {
    if (coins < 30) {
      return this;
    }

    final shuffledWords = List<String>.from(availableWords)..shuffle();
    return copyWith(availableWords: shuffledWords, coins: coins - 30);
  }

  // 레벨 클리어 보상 지급
  GameState rewardLevelClear() {
    if (!isCompleted) {
      return this;
    }
    return copyWith(coins: coins + 10);
  }

  // 상태 복사 함수
  GameState copyWith({
    List<DeckModel>? decks,
    List<String>? availableWords,
    int? hearts,
    int? coins,
    bool? isCompleted,
    bool? isFailed,
  }) {
    return GameState(
      levelModel: levelModel,
      decks: decks ?? this.decks,
      availableWords: availableWords ?? this.availableWords,
      coins: coins ?? this.coins,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}