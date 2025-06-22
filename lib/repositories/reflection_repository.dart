import '../models/reflection.dart';
import '../services/database_service.dart';

abstract class ReflectionRepository {
  Future<Reflection?> getReflectionByDate(DateTime date);
  Future<List<Reflection>> getReflectionsByDateRange(
      DateTime start, DateTime end);
  Future<void> createReflection(Reflection reflection);
  Future<void> updateReflection(Reflection reflection);
}

class ReflectionRepositoryImpl implements ReflectionRepository {
  final DatabaseService _databaseService;

  ReflectionRepositoryImpl(this._databaseService);

  @override
  Future<Reflection?> getReflectionByDate(DateTime date) async {
    final json = await _databaseService.getReflectionByDate(date);
    return json != null ? Reflection.fromJson(json) : null;
  }

  @override
  Future<List<Reflection>> getReflectionsByDateRange(
      DateTime start, DateTime end) async {
    final jsonList =
        await _databaseService.getReflectionsByDateRange(start, end);
    return jsonList.map((json) => Reflection.fromJson(json)).toList();
  }

  @override
  Future<void> createReflection(Reflection reflection) async {
    await _databaseService.insertReflection(reflection.toJson());
  }

  @override
  Future<void> updateReflection(Reflection reflection) async {
    await _databaseService.updateReflection(reflection.toJson());
  }
}
