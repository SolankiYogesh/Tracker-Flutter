import 'package:dio/dio.dart';
import 'package:tracker/models/user_create.dart';
import 'package:tracker/models/user_response.dart';
import 'package:tracker/models/user_update.dart';
import 'package:tracker/network/api_exceptions.dart';
import 'package:tracker/network/dio_client.dart';

class UserRepository {
  final Dio _dio = DioClient().dio;

  Future<UserResponse> createUser(UserCreate user) async {
    try {
      final res = await _dio.post('/api/v1/users', data: user.toJson());
      return UserResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserResponse> getUser(String userId) async {
    try {
      final res = await _dio.get('/api/v1/users/$userId');
      return UserResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserResponse> updateUser(String userId, UserUpdate user) async {
    try {
      final res = await _dio.put('/api/v1/users/$userId', data: user.toJson());
      return UserResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
