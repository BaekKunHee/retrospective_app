import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room.freezed.dart';
part 'chat_room.g.dart';

@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required String name,
    required String description,
    required String ownerId,
    @Default([]) List<String> memberIds,
    @Default(10) int maxMembers,
    @Default(2) int minMembers,
    @Default(true) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

extension ChatRoomExtension on ChatRoom {
  bool get isFull => memberIds.length >= maxMembers;
  bool get canStart => memberIds.length >= minMembers;
}
