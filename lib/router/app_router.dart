import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/chat_rooms_screen.dart';
import '../screens/evening_kpt_screen.dart';
import '../screens/home_screen.dart';
import '../screens/morning_goals_screen.dart';
import '../screens/reflection_history_screen.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String morningGoals = '/morning-goals';
  static const String eveningKPT = '/evening-kpt';
  static const String reflectionHistory = '/reflection-history';
  static const String chatRooms = '/chat-rooms';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: morningGoals,
        name: 'morning-goals',
        builder: (context, state) {
          final previousTryItems = state.extra as List<String>? ?? [];
          return MorningGoalsScreen(previousTryItems: previousTryItems);
        },
      ),
      GoRoute(
        path: eveningKPT,
        name: 'evening-kpt',
        builder: (context, state) => const EveningKPTScreen(),
      ),
      GoRoute(
        path: reflectionHistory,
        name: 'reflection-history',
        builder: (context, state) => const ReflectionHistoryScreen(),
      ),
      GoRoute(
        path: chatRooms,
        name: 'chat-rooms',
        builder: (context, state) => const ChatRoomsScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '요청하신 페이지를 찾을 수 없습니다.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}

// 라우팅 확장 메서드
extension AppRouterExtension on BuildContext {
  void goToHome() => go(AppRouter.home);
  void goToMorningGoals({List<String>? previousTryItems}) =>
      go(AppRouter.morningGoals, extra: previousTryItems);
  void goToEveningKPT() => go(AppRouter.eveningKPT);
  void goToReflectionHistory() => go(AppRouter.reflectionHistory);
  void goToChatRooms() => go(AppRouter.chatRooms);
  void goToSettings() => go(AppRouter.settings);
}
