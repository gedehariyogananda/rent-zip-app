import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      // Temporarily set a dummy user with just the token
      // In a complete app, you'd fetch the user's profile from the API here
      _currentUser = UserModel(token: token);
      notifyListeners();
    }
  }

  // Cek Kredensial & Pengecekan Status Verifikasi
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // Skenario B: User SUDAH Diverifikasi (diberikan token)
        if (data != null && data['token'] != null) {
          _currentUser = UserModel.fromJson(data);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _currentUser!.token!);
        }
        // Skenario A: User BELUM Diverifikasi (tidak ada token, OTP dikirim)
        // _currentUser tidak di-set (atau tidak memiliki token).

        _setLoading(false);
        return true; // Return true agar UI tahu API call sukses
      } else {
        _setErrorMessage(response.data['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP (Actual Login)
  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.post(
        '/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        _currentUser = UserModel.fromJson(data);

        if (_currentUser?.token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _currentUser!.token!);
        }

        _setLoading(false);
        return true;
      } else {
        _setErrorMessage(response.data['message'] ?? 'OTP Verification failed');
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register (Daftar Akun Baru & Kirim OTP)
  Future<bool> register(
    String username,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.post(
        '/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        // Registration success, OTP sent to email. Token not yet provided.
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage(response.data['message'] ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String nik,
    required String address,
    required String noDarurat,
    required String ktpPhotoPath,
    required String photoWithNikPath,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      FormData formData = FormData.fromMap({
        'nik': nik,
        'address': address,
        'no_darurat': noDarurat,
        'ktp_photo': await MultipartFile.fromFile(ktpPhotoPath),
        'photo_with_nik': await MultipartFile.fromFile(photoWithNikPath),
      });

      final response = await _apiClient.post('/profile', data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _setErrorMessage(
          response.data['message'] ?? 'Failed to update profile',
        );
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Cek Kelengkapan Profil
  Future<bool?> checkProfile() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.get('/profile/check');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        _setLoading(false);
        return data['is_verified'] == true;
      } else {
        _setErrorMessage(response.data['message'] ?? 'Failed to check profile');
        _setLoading(false);
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
      return null;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // Logout
  Future<bool> logout() async {
    _setLoading(true);
    try {
      final response = await _apiClient.post('/logout');

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        _currentUser = null;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } on DioException catch (e) {
      // Even if API fails, clear local token to prevent getting stuck
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _currentUser = null;
      _handleDioError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        // Validation errors usually come in arrays under specific keys
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            _setErrorMessage(firstError.first.toString());
            return;
          }
        }

        // General error messages often just named 'message' or fallback to a key
        if (responseData.containsKey('message')) {
          _setErrorMessage(responseData['message']);
        } else {
          // If the validation errors are directly on the root object (like {"username":["..."]})
          final firstKey = responseData.keys.first;
          final firstValue = responseData[firstKey];
          if (firstValue is List && firstValue.isNotEmpty) {
            _setErrorMessage(firstValue.first.toString());
          } else {
            _setErrorMessage('Error: ${e.response?.statusCode}');
          }
        }
      } else {
        _setErrorMessage(
          'Error: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      }
    } else {
      _setErrorMessage(
        'Network error: Ensure your backend is running and accessible.',
      );
    }
  }
}
