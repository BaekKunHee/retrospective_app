import 'package:freezed_annotation/freezed_annotation.dart';

part 'reflection.freezed.dart';
part 'reflection.g.dart';

@freezed
class Reflection with _$Reflection {
  const factory Reflection({
    required String id,
    required DateTime date,
    @Default([]) List<String> morningGoals,
    String? keep,
    String? problem,
    @Default([]) List<String> tryItems,
    @Default(false) bool isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Reflection;

  factory Reflection.fromJson(Map<String, dynamic> json) =>
      _$ReflectionFromJson(json);
}
