import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/reflection.dart';
import '../models/user.dart';
import '../repositories/reflection_repository.dart';
import '../repositories/user_repository.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'app_state_provider.dart';

// Export for use in screens
export 'app_state_provider.dart';

part 'app_providers.g.dart';

// Services
final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(databaseServiceProvider));
});

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  return ReflectionRepositoryImpl(ref.read(databaseServiceProvider));
});

// App State Provider (기존 방식과 호환성 유지)
final appStateProvider =
    Provider<AppStateProvider>((ref) => AppStateProvider());

// StateNotifier Provider (나중에 마이그레이션할 때 사용)
// final appStateNotifierProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
//   return AppStateNotifier(
//     ref.read(userRepositoryProvider),
//     ref.read(reflectionRepositoryProvider),
//   );
// });

// State Providers
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  User? build() {
    return null;
  }

  Future<void> loadUser(String userId) async {
    final repository = ref.read(userRepositoryProvider);
    state = await repository.getUserById(userId);
  }

  Future<void> updateUser(User user) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updateUser(user);
    state = user;
  }
}

@riverpod
class TodayReflection extends _$TodayReflection {
  @override
  Reflection? build() {
    return null;
  }

  Future<void> loadTodayReflection() async {
    final repository = ref.read(reflectionRepositoryProvider);
    final today = DateTime.now();
    state = await repository.getReflectionByDate(today);
  }

  Future<void> saveReflection(Reflection reflection) async {
    final repository = ref.read(reflectionRepositoryProvider);

    if (state?.id == reflection.id) {
      await repository.updateReflection(reflection);
    } else {
      await repository.createReflection(reflection);
    }

    state = reflection;
  }
}

@riverpod
class RecentReflections extends _$RecentReflections {
  @override
  List<Reflection> build() {
    return [];
  }

  Future<void> loadRecentReflections() async {
    final repository = ref.read(reflectionRepositoryProvider);
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    state = await repository.getReflectionsByDateRange(startDate, endDate);
  }
}

// Computed Providers
@riverpod
bool canUseGroupFeatures(CanUseGroupFeaturesRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canUseGroupFeatures ?? false;
}

@riverpod
bool canJoinMoreChatRooms(CanJoinMoreChatRoomsRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canJoinMoreChatRooms ?? false;
}

@riverpod
List<String> previousDayTryItems(PreviousDayTryItemsRef ref) {
  final reflections = ref.watch(recentReflectionsProvider);

  if (reflections.isEmpty) return [];

  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final yesterdayStart =
      DateTime(yesterday.year, yesterday.month, yesterday.day);

  for (final reflection in reflections) {
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
