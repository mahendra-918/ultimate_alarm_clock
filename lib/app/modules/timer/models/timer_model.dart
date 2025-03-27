import 'package:isar/isar.dart';

part 'timer_model.g.dart';

@collection
class TimerModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  int timerId;
  
  Duration duration;
  Duration remainingTime;
  bool isRunning;
  DateTime? startTime;
  DateTime? endTime;

  TimerModel({
    required this.timerId,
    required this.duration,
    required this.remainingTime,
    this.isRunning = false,
    this.startTime,
    this.endTime,
  });
} 