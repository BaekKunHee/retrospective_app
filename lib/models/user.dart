import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(0) int reflectionCount,
    @Default([]) List<String> joinedChatRoomIds,
    DateTime? morningNotificationTime,
    DateTime? eveningNotificationTime,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserExtension on User {
  // 그룹 기능 사용 권한 체크 (90일 내 30회 이상 회고 작성)
  bool get canUseGroupFeatures => reflectionCount >= 30;

  // 최대 5개 채팅룸 참여 제한 체크
  bool get canJoinMoreChatRooms => joinedChatRoomIds.length < 5;
}
