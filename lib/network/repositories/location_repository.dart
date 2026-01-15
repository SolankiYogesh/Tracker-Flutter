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
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/locations/batch',
        data: batch.toJson(),
      );

      return BatchUploadResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getRealtimeLocation(String userId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/locations/realtime/$userId');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<NearbyUser>> getNearbyUsers(String userId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/locations/nearby/$userId',
        queryParameters: {'limit': 100, 'radius': 5000000},
      );
      final List<dynamic> users = (res.data as Map<String, dynamic>)['nearby_users'] as List<dynamic>? ?? [];
      return users.map((e) => NearbyUser.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
