import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;

  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
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

  // Fetch all orders
  Future<void> fetchOrders({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (startDate != null && startDate.isNotEmpty)
        queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty)
        queryParams['end_date'] = endDate;

      final response = await _apiClient.get(
        '/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // Handle both paginated response or direct list response
        final List<dynamic> items = data is List ? data : (data['data'] ?? []);

        _orders = items.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        _setErrorMessage(response.data['message'] ?? 'Failed to fetch orders');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch order detail by ID
  Future<void> fetchOrderById(int id) async {
    _setLoading(true);
    _setErrorMessage(null);
    _selectedOrder = null;

    try {
      final response = await _apiClient.get('/orders/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          _selectedOrder = OrderModel.fromJson(data);
        }
      } else {
        _setErrorMessage(response.data['message'] ?? 'Order not found');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Confirm payment
  Future<bool> confirmPayment(int id) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.put('/orders/$id/confirm-payment');

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (_selectedOrder != null && _selectedOrder!.id == id) {
          final data = response.data['data'];
          if (data != null) {
            _selectedOrder = OrderModel.fromJson(data);
          }
        }
        return true;
      } else {
        _setErrorMessage(
          response.data['message'] ?? 'Failed to confirm payment',
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
