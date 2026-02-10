import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';
import '../../data/models/train_model.dart';

class TrainService {
  List<TrainModel> _trains = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/trains.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _trains = jsonList.map((json) => TrainModel.fromJson(json)).toList();
      _initialized = true;
      AppLogger.debug('Initialized TrainService with ${_trains.length} trains');
    } catch (e, stack) {
      AppLogger.debug('Failed to load trains', e, stack);
    }
  }

  List<TrainModel> searchTrains(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _trains.where((train) {
      return train.number.contains(lowercaseQuery) || 
             train.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  TrainModel? getTrainByNumber(String number) {
    try {
      return _trains.firstWhere((train) => train.number == number);
    } catch (_) {
      return null;
    }
  }
}
