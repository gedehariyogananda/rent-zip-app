import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';

class AdminOrderViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fetch all orders for admin
  Future<void> fetchOrders({
    String? status,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await _apiClient.get(
        '/admin/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> items = data is List ? data : (data['data'] ?? []);
        _orders = items.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        _setErrorMessage(
          response.data['message'] ?? 'Failed to fetch admin orders',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Verify payment
  Future<bool> verifyPayment(int id) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.patch('/admin/orders/$id/verify');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Optionally update the local list or re-fetch
        final index = _orders.indexWhere((o) => o.id == id);
        if (index != -1) {
          // You might want to do a full refetch here instead, depending on your UI needs
          fetchOrders();
        }
        return true;
      } else {
        _setErrorMessage(
          response.data['message'] ?? 'Failed to verify payment',
        );
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel order
  Future<bool> cancelOrder(int id) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.patch('/admin/orders/$id/cancel');

      if (response.statusCode == 200 && response.data['success'] == true) {
        fetchOrders(); // Refresh list to reflect changes
        return true;
      } else {
        _setErrorMessage(response.data['message'] ?? 'Failed to cancel order');
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Complete/Done order
  Future<bool> completeOrder(int id) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.patch('/admin/orders/$id/done');

      if (response.statusCode == 200 && response.data['success'] == true) {
        fetchOrders(); // Refresh list to reflect changes
        return true;
      } else {
        _setErrorMessage(
          response.data['message'] ?? 'Failed to complete order',
        );
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get static QRIS image URL
  Future<String?> getStaticQris() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.get('/orders/qris');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return data['qris_image_url']?.toString();
      } else {
        _setErrorMessage(response.data['message'] ?? 'Failed to load QRIS');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    } catch (e) {
      _setErrorMessage(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        _setErrorMessage(responseData['message']);
      } else {
        _setErrorMessage('Error: ${e.response?.statusCode}');
      }
    } else {
      _setErrorMessage('Network error: Please check your connection.');
    }
  }
}
