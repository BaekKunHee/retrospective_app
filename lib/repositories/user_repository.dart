import '../models/user.dart';
import '../services/database_service.dart';

abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<int> getReflectionCountForLast90Days();
}

class UserRepositoryImpl implements UserRepository {
  final DatabaseService _databaseService;

  UserRepositoryImpl(this._databaseService);

  @override
  Future<User?> getUserById(String id) async {
    final json = await _databaseService.getUserById(id);
    return json != null ? User.fromJson(json) : null;
  }

  @override
  Future<void> createUser(User user) async {
    await _databaseService.insertUser(user.toJson());
  }

  @override
  Future<void> updateUser(User user) async {
    await _databaseService.updateUser(user.toJson());
  }

  @override
  Future<int> getReflectionCountForLast90Days() async {
    return await _databaseService.getReflectionCountForLast90Days();
  }
}
