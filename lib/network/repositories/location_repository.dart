import 'package:dio/dio.dart';
import 'package:tracker/models/batch_upload_response.dart';
import 'package:tracker/models/location_batch.dart';
import 'package:tracker/models/nearby_user.dart';
import 'package:tracker/network/api_exceptions.dart';
import 'package:tracker/network/dio_client.dart';

class LocationRepository {
  final Dio _dio = DioClient().dio;

  Future<BatchUploadResponse> uploadBatch(LocationBatch batch) async {
    try {
      final res = await _dio.post(
        '/api/v1/locations/batch',
        data: batch.toJson(),
      );

      return BatchUploadResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getRealtimeLocation(String userId) async {
    try {
      final res = await _dio.get('/api/v1/locations/realtime/$userId');
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<NearbyUser>> getNearbyUsers(String userId) async {
    try {
      final res = await _dio.get(
        '/api/v1/locations/nearby/$userId',
        queryParameters: {'limit': 10, 'radius': 5000},
      );
      final List users = res.data['nearby_users'] ?? [];
      return users.map((e) => NearbyUser.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
