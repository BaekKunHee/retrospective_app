import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/reflection.dart';
import '../providers/app_providers.dart';

class ReflectionHistoryScreen extends ConsumerWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회고 기록'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final appState = ref.watch(appStateProvider);
          final reflections = appState.recentReflections;

          if (reflections.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '아직 작성된 회고가 없습니다.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '첫 번째 회고를 작성해보세요!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reflections.length,
            itemBuilder: (context, index) {
              final reflection = reflections[index];
              return _buildReflectionCard(context, reflection);
            },
          );
        },
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, Reflection reflection) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reflection.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: reflection.isCompleted ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(reflection.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (reflection.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (reflection.morningGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                '아침 목표',
                Icons.flag,
                Colors.blue,
                reflection.morningGoals.map((goal) => '• $goal').join('\n'),
              ),
            ],
            if (reflection.keep?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Keep',
                Icons.thumb_up,
                Colors.green,
                reflection.keep!,
              ),
            ],
            if (reflection.problem?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Problem',
                Icons.error_outline,
                Colors.orange,
                reflection.problem!,
              ),
            ],
            if (reflection.tryItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Try',
                Icons.lightbulb_outline,
                Colors.purple,
                reflection.tryItems.map((item) => '• $item').join('\n'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
