// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      reflectionCount: (json['reflectionCount'] as num?)?.toInt() ?? 0,
      joinedChatRoomIds: (json['joinedChatRoomIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      morningNotificationTime: json['morningNotificationTime'] == null
          ? null
          : DateTime.parse(json['morningNotificationTime'] as String),
      eveningNotificationTime: json['eveningNotificationTime'] == null
          ? null
          : DateTime.parse(json['eveningNotificationTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'reflectionCount': instance.reflectionCount,
      'joinedChatRoomIds': instance.joinedChatRoomIds,
      'morningNotificationTime':
          instance.morningNotificationTime?.toIso8601String(),
      'eveningNotificationTime':
          instance.eveningNotificationTime?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
