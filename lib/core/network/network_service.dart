import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../preferences/secure_storage_manager.dart';
import '../preferences/shared_preferences_manager.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? rawData;

  ApiResponse({required this.success, this.message, this.data, this.statusCode, this.rawData});

  /// S U C C E S S - ApiResponse
  factory ApiResponse.success({required T? data, String? message, int? statusCode, Map<String, dynamic>? rawData}) {
    return ApiResponse(success: true, data: data, message: message, statusCode: statusCode, rawData: rawData);
  }

  /// E R R O R - ApiResponse
  factory ApiResponse.error({String? message, int? statusCode, Map<String, dynamic>? rawData}) {
    return ApiResponse(success: false, message: message, statusCode: statusCode, rawData: rawData);
  }
}

///
class NetworkService {
  final Dio _dio;
  static const String _baseUrl = 'https://osmanlica.online/api';
  final SecureStorageManager _secureStorage;
  final SharedPreferencesManager _sharedPreferences;

  NetworkService(this._dio)
    : _secureStorage = GetIt.instance<SecureStorageManager>(),
      _sharedPreferences = GetIt.instance<SharedPreferencesManager>() {
    _configureBaseOptions();
    _addInterceptors();
  }

  /// Dio nesnesinin [temel ayarlarını] yapılandırır.
  void _configureBaseOptions() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  /// Dio nesnesine [interceptor]lar ekler.
  /// Bu interceptor'lar, [istek ve yanıt loglaması], [hata yönetimi] ve [token yönetimi] gibi işlemleri gerçekleştirir.
  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          //_logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          //_logResponse(response);
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          //_logError(e);
          return handler.next(e);
        },
      ),
    );

    // [Token interceptor]u ekle
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// [İstek] detaylarını loglar.
  void _logRequest(RequestOptions options) {
    log('REQUEST[${options.method}] => PATH: ${options.path}');
    log('REQUEST DATA => ${options.data}');
    log('REQUEST HEADERS => ${options.headers}');
  }

  /// [Yanıt] detaylarını loglar.
  void _logResponse(Response response) {
    log('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    log('RESPONSE DATA => ${response.data}');
  }

  /// [Hata] detaylarını loglar.
  void _logError(DioException e) {
    log('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
    log('ERROR DATA => ${e.response?.data}');
    log('ERROR MESSAGE => ${e.message}');
    log('ERROR TYPE => ${e.type}');
  }

  /// Token'ı SecureStorage'a kaydeder.
  Future<void> saveToken(String token) async {
    await _secureStorage.saveAccessToken(token);
  }

  /// Token'ı SecureStorage'dan alır.
  Future<String?> getToken() async {
    return await _secureStorage.getAccessToken();
  }

  /// Token'ı SecureStorage'dan siler.
  Future<void> removeToken() async {
    await _secureStorage.remove(SecureStorageManager.keyAccessToken);
  }

  /// Kullanıcının giriş yapmış olup olmadığını kontrol eder.
  Future<bool> isLoggedIn() async {
    return await _sharedPreferences.isUserLoggedIn();
  }

  /// [endpoint] parametresi, istek yapılacak endpoint'i belirtir.
  /// [queryParameters] parametresi, istek için query parametrelerini belirtir.
  /// [options] parametresi, istek için ek seçenekleri belirtir.
  /// [fromJson] parametresi, yanıt verilerini dönüştürmek için kullanılacak fonksiyonu belirtir.
  /// [fromJsonList] parametresi, yanıt verilerini dönüştürmek için kullanılacak fonksiyonu belirtir.

  /// GET isteği gönderir ve ApiResponse döndürür.
  Future<ApiResponse<T>> getResponse<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  }) async {
    try {
      final response = await get(endpoint, queryParameters: queryParameters, options: options);

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // -->Eğer yanıt bir [Map] ise ve ['data' anahtarı] varsa
        if (response.data is Map<String, dynamic>) {
          if (fromJson != null && response.data['data'] != null) {
            // ->Eğer 'data' bir [liste] ise ve [fromJsonList] sağlanmışsa
            if (response.data['data'] is List && fromJsonList != null) {
              return ApiResponse.success(
                data: fromJsonList(response.data['data']),
                message: response.data['message'],
                statusCode: response.statusCode,
                rawData: response.data,
              );
            }
            // ->Eğer 'data' bir [Map] ise ve [fromJson] sağlanmışsa
            else if (response.data['data'] is Map<String, dynamic>) {
              return ApiResponse.success(
                data: fromJson(response.data['data']),
                message: response.data['message'],
                statusCode: response.statusCode,
                rawData: response.data,
              );
            }
          }
          return ApiResponse.success(data: null, message: response.data['message'], statusCode: response.statusCode, rawData: response.data);
        }
        // -->Eğer yanıt doğrudan bir [List] ise
        else if (response.data is List && fromJsonList != null) {
          return ApiResponse.success(data: fromJsonList(response.data), statusCode: response.statusCode);
        }
      }

      return ApiResponse.error(
        message: response.data is Map ? response.data['message'] ?? 'Bir hata oluştu' : 'Bir hata oluştu',
        statusCode: response.statusCode,
        rawData: response.data is Map ? response.data : null,
      );
    } catch (e) {
      log('GET isteği sırasında hata oluştu: $e');
      return ApiResponse.error(
        message: e is DioException ? e.message : e.toString(),
        statusCode: e is DioException ? e.response?.statusCode : null,
        rawData: e is DioException ? e.response?.data : null,
      );
    }
  }

  /// POST isteği gönderir ve ApiResponse döndürür.
  Future<ApiResponse<T>> postResponse<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await post(endpoint, data: data, queryParameters: queryParameters, options: options);

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (fromJson != null && response.data['data'] != null) {
          return ApiResponse.success(
            data: fromJson(response.data['data']),
            message: response.data['message'],
            statusCode: response.statusCode,
            rawData: response.data,
          );
        }

        return ApiResponse.success(data: null, message: response.data['message'], statusCode: response.statusCode, rawData: response.data);
      }

      return ApiResponse.error(message: response.data['message'] ?? 'Bir hata oluştu', statusCode: response.statusCode, rawData: response.data);
    } catch (e) {
      log('POST isteği sırasında hata oluştu: $e');
      return ApiResponse.error(
        message: e is DioException ? e.message : e.toString(),
        statusCode: e is DioException ? e.response?.statusCode : null,
        rawData: e is DioException ? e.response?.data : null,
      );
    }
  }

  /// PUT isteği gönderir ve ApiResponse döndürür.
  Future<ApiResponse<T>> putResponse<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await put(endpoint, data: data, queryParameters: queryParameters, options: options);

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final Map<String, dynamic> responseData = response.data;

        if (fromJson != null && responseData['data'] != null) {
          final T data = fromJson(responseData['data']);
          return ApiResponse.success(data: data, message: responseData['message'], statusCode: response.statusCode, rawData: responseData);
        }

        return ApiResponse.success(data: null, message: responseData['message'], statusCode: response.statusCode, rawData: responseData);
      }

      return ApiResponse.error(message: response.data['message'] ?? 'Bir hata oluştu', statusCode: response.statusCode, rawData: response.data);
    } catch (e) {
      log('PUT isteği sırasında hata oluştu: $e');
      return ApiResponse.error(
        message: e is DioException ? e.message : e.toString(),
        statusCode: e is DioException ? e.response?.statusCode : null,
        rawData: e is DioException ? e.response?.data : null,
      );
    }
  }

  /// DELETE isteği gönderir ve ApiResponse döndürür.
  Future<ApiResponse<T>> deleteResponse<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await delete(endpoint, data: data, queryParameters: queryParameters, options: options);

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final Map<String, dynamic> responseData = response.data;

        if (fromJson != null && responseData['data'] != null) {
          final T data = fromJson(responseData['data']);
          return ApiResponse.success(data: data, message: responseData['message'], statusCode: response.statusCode, rawData: responseData);
        }

        return ApiResponse.success(data: null, message: responseData['message'], statusCode: response.statusCode, rawData: responseData);
      }

      return ApiResponse.error(message: response.data['message'] ?? 'Bir hata oluştu', statusCode: response.statusCode, rawData: response.data);
    } catch (e) {
      log('DELETE isteği sırasında hata oluştu: $e');
      return ApiResponse.error(
        message: e is DioException ? e.message : e.toString(),
        statusCode: e is DioException ? e.response?.statusCode : null,
        rawData: e is DioException ? e.response?.data : null,
      );
    }
  }

  /// GET isteği gönderir.
  ///
  /// [endpoint] parametresi, istek yapılacak endpoint'i belirtir.
  /// [queryParameters] parametresi, istek için query parametrelerini belirtir.
  /// [options] parametresi, istek için ek seçenekleri belirtir.
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters, options: options);
      return _validateResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST isteği gönderir.
  Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters, options: options);
      return _validateResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT isteği gönderir.
  Future<Response> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.put(endpoint, data: data, queryParameters: queryParameters, options: options);
      return _validateResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE isteği gönderir.
  Future<Response> delete(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.delete(endpoint, data: data, queryParameters: queryParameters, options: options);
      return _validateResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Yanıtı doğrular ve geçerli bir yanıt döndürür.
  /// [response] parametresi, doğrulanacak yanıtı belirtir.
  Response _validateResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response;
    } else {
      throw DioException(requestOptions: response.requestOptions, response: response, error: 'Unexpected status code: ${response.statusCode}');
    }
  }

  /// Hata durumunu ele alır ve uygun bir yanıt döndürür.
  /// [error] parametresi, ele alınacak hatayı belirtir.
  Future<Response> _handleError(dynamic error) async {
    if (error is DioException) {
      // Token hatası durumunda token'ı sil
      if (error.response?.statusCode == 401) {
        await removeToken();
      }

      // Hata yanıtını döndür
      if (error.response != null) {
        return error.response!;
      }

      // Yanıt yoksa yeni bir hata yanıtı oluştur
      throw error;
    } else {
      // Dio hatası değilse, genel bir hata fırlat
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: error.toString(),
      );
    }
  }
}
