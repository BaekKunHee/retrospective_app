import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_room.dart';
import '../models/reflection.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AppStateProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  Reflection? _todayReflection;
  List<Reflection> _recentReflections = [];
  List<ChatRoom> _chatRooms = [];
  List<ChatRoom> _joinedChatRooms = [];

  // Getters
  User? get currentUser => _currentUser;
  Reflection? get todayReflection => _todayReflection;
  List<Reflection> get recentReflections => _recentReflections;
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatRoom> get joinedChatRooms => _joinedChatRooms;

  bool get isLoggedIn => _currentUser != null;
  bool get canUseGroupFeatures => _currentUser?.canUseGroupFeatures ?? false;
  bool get canJoinMoreChatRooms => _currentUser?.canJoinMoreChatRooms ?? false;

  // Initialize app state
  Future<void> initializeApp() async {
    // 임시로 더미 사용자 생성 (실제 앱에서는 로그인 시스템 구현)
    await _loadOrCreateDummyUser();
    await loadTodayReflection();
    await loadRecentReflections();
    await loadChatRooms();
  }

  Future<void> _loadOrCreateDummyUser() async {
    // 실제 앱에서는 SharedPreferences에서 사용자 ID를 가져와 로드
    const userId = 'user_001';
    final userJson = await _databaseService.getUserById(userId);

    User? user;
    if (userJson != null) {
      user = User.fromJson(userJson);
    } else {
      // 더미 사용자 생성
      user = User(
        id: userId,
        name: '회고 러버',
        email: 'user@example.com',
        createdAt: DateTime.now(),
      );
      await _databaseService.insertUser(user.toJson());
    }

    _currentUser = user;
    notifyListeners();
  }

  // Reflection methods
  Future<void> loadTodayReflection() async {
    if (_currentUser == null) return;

    final today = DateTime.now();
    final reflectionJson = await _databaseService.getReflectionByDate(today);

    if (reflectionJson != null) {
      _todayReflection = Reflection.fromJson(reflectionJson);
    } else {
      _todayReflection = Reflection(
        id: _uuid.v4(),
        date: DateTime(today.year, today.month, today.day),
        createdAt: DateTime.now(),
      );
    }

    notifyListeners();
  }

  Future<void> loadRecentReflections() async {
    if (_currentUser == null) return;

    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final reflectionJsonList =
        await _databaseService.getReflectionsByDateRange(startDate, endDate);
    _recentReflections =
        reflectionJsonList.map((json) => Reflection.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> saveMorningGoals(List<String> goals) async {
    if (_todayReflection == null) return;

    final updatedReflection = _todayReflection!.copyWith(
      morningGoals: goals,
      updatedAt: DateTime.now(),
    );

    if (_todayReflection!.createdAt == null) {
      // 새 회고 저장
      await _databaseService.insertReflection(updatedReflection.toJson());
    } else {
      // 기존 회고 업데이트
      await _databaseService.updateReflection(updatedReflection.toJson());
    }

    _todayReflection = updatedReflection;
    notifyListeners();
  }

  Future<void> saveEveningKPT(
      String keep, String problem, List<String> tryItems) async {
    if (_todayReflection == null) return;

    final updatedReflection = _todayReflection!.copyWith(
      keep: keep,
      problem: problem,
      tryItems: tryItems,
      isCompleted: true,
      updatedAt: DateTime.now(),
    );

    await _databaseService.updateReflection(updatedReflection.toJson());

    // 사용자 회고 카운트 업데이트
    if (_currentUser != null) {
      final count = await _databaseService.getReflectionCountForLast90Days();
      final updatedUser = _currentUser!.copyWith(
        reflectionCount: count,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateUser(updatedUser.toJson());
      _currentUser = updatedUser;
    }

    _todayReflection = updatedReflection;
    await loadRecentReflections();
    notifyListeners();
  }

  List<String> getPreviousDayTryItems() {
    if (_recentReflections.isEmpty) return [];

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart =
        DateTime(yesterday.year, yesterday.month, yesterday.day);

    for (final reflection in _recentReflections) {
      final reflectionDate = DateTime(
        reflection.date.year,
        reflection.date.month,
        reflection.date.day,
      );

      if (reflectionDate.isAtSameMomentAs(yesterdayStart)) {
        return reflection.tryItems;
      }
    }

    return [];
  }

  // Chat room methods
  Future<void> loadChatRooms() async {
    if (_currentUser == null) return;

    _chatRooms = await _databaseService.getAllChatRooms();
    _joinedChatRooms =
        await _databaseService.getChatRoomsByUserId(_currentUser!.id);
    notifyListeners();
  }

  Future<bool> createChatRoom(
      String name, String description, int maxMembers, int minMembers) async {
    if (_currentUser == null || !canUseGroupFeatures) return false;

    final chatRoom = ChatRoom(
      id: _uuid.v4(),
      name: name,
      description: description,
      ownerId: _currentUser!.id,
      memberIds: [_currentUser!.id],
      maxMembers: maxMembers,
      minMembers: minMembers,
      createdAt: DateTime.now(),
    );

    await _databaseService.insertChatRoom(chatRoom);
    await loadChatRooms();

    return true;
  }

  Future<bool> joinChatRoom(String chatRoomId) async {
    if (_currentUser == null || !canJoinMoreChatRooms) return false;

    final chatRoom = await _databaseService.getChatRoomById(chatRoomId);
    if (chatRoom == null || chatRoom.isFull) return false;

    final updatedMemberIds = [...chatRoom.memberIds, _currentUser!.id];
    final updatedChatRoom = chatRoom.copyWith(
      memberIds: updatedMemberIds,
      updatedAt: DateTime.now(),
    );

    await _databaseService.updateChatRoom(updatedChatRoom);
    await loadChatRooms();

    return true;
  }

  Future<bool> leaveChatRoom(String chatRoomId) async {
    if (_currentUser == null) return false;

    final chatRoom = await _databaseService.getChatRoomById(chatRoomId);
    if (chatRoom == null) return false;

    final updatedMemberIds =
        chatRoom.memberIds.where((id) => id != _currentUser!.id).toList();
    final updatedChatRoom = chatRoom.copyWith(
      memberIds: updatedMemberIds,
      updatedAt: DateTime.now(),
    );

    await _databaseService.updateChatRoom(updatedChatRoom);
    await loadChatRooms();

    return true;
  }

  // Notification settings
  Future<void> updateNotificationTimes(
      DateTime? morning, DateTime? evening) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      morningNotificationTime: morning,
      eveningNotificationTime: evening,
      updatedAt: DateTime.now(),
    );

    await _databaseService.updateUser(updatedUser.toJson());
    _currentUser = updatedUser;
    notifyListeners();
  }
}
