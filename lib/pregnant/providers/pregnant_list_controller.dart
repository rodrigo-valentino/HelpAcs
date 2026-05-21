import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pregnant_woman_model.dart';
import '../../utils/hive_keys.dart';

final pregnantListProvider =
    NotifierProvider<PregnantListNotifier, List<PregnantWomanModel>>(() {
  return PregnantListNotifier();
});

class PregnantListNotifier extends Notifier<List<PregnantWomanModel>> {
  Box<PregnantWomanModel> get _box => Hive.box<PregnantWomanModel>(HiveKeys.pregnantBox);

  @override
  List<PregnantWomanModel> build() {
    return _box.values.toList();
  }

  Future<void> addPregnant(PregnantWomanModel woman) async {
    await _box.add(woman);
    _refreshState();
  }

  Future<void> updatePregnant(PregnantWomanModel woman) async {
    await woman.save();
    _refreshState();
  }

  Future<void> deletePregnant(PregnantWomanModel woman) async {
    await woman.delete();
    _refreshState();
  }

  void refresh() => _refreshState();

  void _refreshState() {
    state = _box.values.toList();
  }
}