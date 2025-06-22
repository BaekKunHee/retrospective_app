// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReflectionImpl _$$ReflectionImplFromJson(Map<String, dynamic> json) =>
    _$ReflectionImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      morningGoals: (json['morningGoals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      keep: json['keep'] as String?,
      problem: json['problem'] as String?,
      tryItems: (json['tryItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ReflectionImplToJson(_$ReflectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'morningGoals': instance.morningGoals,
      'keep': instance.keep,
      'problem': instance.problem,
      'tryItems': instance.tryItems,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
