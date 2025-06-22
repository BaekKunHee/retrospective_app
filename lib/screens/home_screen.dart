import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/app_providers.dart';
import 'chat_rooms_screen.dart';
import 'evening_kpt_screen.dart';
import 'morning_goals_screen.dart';
import 'reflection_history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appStateProvider).initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Retrospective'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final appState = ref.watch(appStateProvider);

          if (!appState.isLoggedIn) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context, appState),
                const SizedBox(height: 16),
                _buildTodayReflectionCard(context, appState),
                const SizedBox(height: 16),
                _buildProgressCard(context, appState),
                const SizedBox(height: 16),
                _buildGroupFeaturesCard(context, appState),
                const SizedBox(height: 16),
                _buildQuickActionsCard(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppStateProvider appState) {
    final user = appState.currentUser!;
    final today = DateFormat('M월 d일 EEEE', 'ko_KR').format(DateTime.now());

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.name[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요, ${user.name}님!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayReflectionCard(
      BuildContext context, AppStateProvider appState) {
    final reflection = appState.todayReflection;
    final previousTryItems = appState.getPreviousDayTryItems();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘의 회고',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 아침 목표 섹션
            _buildReflectionSection(
              context,
              '아침 목표',
              reflection?.morningGoals.isNotEmpty == true
                  ? '${reflection!.morningGoals.length}개 목표 설정 완료'
                  : '아직 목표를 설정하지 않았어요',
              reflection?.morningGoals.isNotEmpty == true,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MorningGoalsScreen(
                      previousTryItems: previousTryItems,
                    ),
                  ),
                );
              },
            ),

            const Divider(height: 24),

            // 저녁 KPT 섹션
            _buildReflectionSection(
              context,
              '저녁 KPT 회고',
              reflection?.isCompleted == true
                  ? 'KPT 회고 완료'
                  : '아직 회고를 작성하지 않았어요',
              reflection?.isCompleted == true,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EveningKPTScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionSection(
    BuildContext context,
    String title,
    String status,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, AppStateProvider appState) {
    final user = appState.currentUser!;
    final recentReflections = appState.recentReflections;
    final completedCount = recentReflections.where((r) => r.isCompleted).length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '나의 성장',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem(
                  context,
                  '총 회고',
                  '${user.reflectionCount}회',
                  Icons.book,
                ),
                _buildProgressItem(
                  context,
                  '이번 달',
                  '$completedCount회',
                  Icons.calendar_month,
                ),
                _buildProgressItem(
                  context,
                  '연속 일수',
                  '${_calculateStreak(recentReflections)}일',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildGroupFeaturesCard(
      BuildContext context, AppStateProvider appState) {
    final canUseGroupFeatures = appState.canUseGroupFeatures;
    final reflectionCount = appState.currentUser?.reflectionCount ?? 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group,
                  color: canUseGroupFeatures
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '그룹 회고',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: canUseGroupFeatures ? null : Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (canUseGroupFeatures) ...[
              Text(
                '그룹 회고 기능을 사용할 수 있습니다!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatRoomsScreen(),
                      ),
                    );
                  },
                  child: const Text('그룹 회고 참여하기'),
                ),
              ),
            ] else ...[
              Text(
                '그룹 회고 기능을 사용하려면 90일 내에 30회 이상의 개인 회고를 완료해야 합니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: reflectionCount / 30,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '진행률: $reflectionCount/30 (${(reflectionCount / 30 * 100).toInt()}%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(
      BuildContext context, AppStateProvider appState) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 메뉴',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  context,
                  Icons.history,
                  '회고 기록',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  context,
                  Icons.analytics,
                  '리포트',
                  () {
                    // TODO: 리포트 화면 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('리포트 기능 준비 중입니다.')),
                    );
                  },
                ),
                _buildQuickActionButton(
                  context,
                  Icons.share,
                  '공유',
                  () {
                    // TODO: 공유 기능
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능 준비 중입니다.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateStreak(List<dynamic> reflections) {
    // 간단한 연속 일수 계산 로직
    // 실제 구현에서는 더 정교한 로직이 필요
    return reflections.take(7).length;
  }
}
