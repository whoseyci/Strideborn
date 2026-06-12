import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/db_service.dart';

class PlayerState {
  final int stepBank;
  final int gold;
  final int tokenBank;
  final int honourPoints;
  final String characterName;

  const PlayerState({
    required this.stepBank,
    required this.gold,
    required this.tokenBank,
    required this.honourPoints,
    required this.characterName,
  });

  PlayerState copyWith({
    int? stepBank,
    int? gold,
    int? tokenBank,
    int? honourPoints,
    String? characterName,
  }) {
    return PlayerState(
      stepBank: stepBank ?? this.stepBank,
      gold: gold ?? this.gold,
      tokenBank: tokenBank ?? this.tokenBank,
      honourPoints: honourPoints ?? this.honourPoints,
      characterName: characterName ?? this.characterName,
    );
  }
}

class PlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    final cur = DbService.save;
    return PlayerState(
      stepBank: cur.stepBank,
      gold: cur.gold,
      tokenBank: cur.tokenBank,
      honourPoints: cur.honourPoints,
      characterName: cur.characterName,
    );
  }

  Future<void> updateGold(int delta) async {
    final next = state.gold + delta;
    state = state.copyWith(gold: next);
    await DbService.updateSave((s) => s.gold = next);
  }

  Future<void> updateStepBank(int amount) async {
    state = state.copyWith(stepBank: amount);
    await DbService.updateSave((s) => s.stepBank = amount);
  }

  Future<void> addSteps(int steps) async {
    final next = state.stepBank + steps;
    state = state.copyWith(stepBank: next);
    await DbService.updateSave((s) => s.stepBank = next);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(() {
  return PlayerNotifier();
});
