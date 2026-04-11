import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
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

  // 1. Get All Notifications
  Future<void> fetchAllNotifications() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _apiClient.get('/notifications');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        _notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        _setLoading(false);
      } else {
        _setErrorMessage(
          response.data['message'] ?? 'Failed to fetch notifications',
        );
        _setLoading(false);
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
    }
  }

  // 2. Get Unread Notifications (and update badge count)
  Future<void> fetchUnreadNotifications() async {
    try {
      final response = await _apiClient.get('/notifications/unread');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['count'] != null) {
          _unreadCount = data['count'];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
    }
  }

  // 3. Mark One Notification As Read
  Future<bool> markAsRead(int id) async {
    try {
      final response = await _apiClient.patch('/notifications/$id/read');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Update local list to reflect changes without re-fetching
        final index = _notifications.indexWhere((notif) => notif.id == id);
        if (index != -1) {
          // Decrement unread count if it was unread
          if (_notifications[index].isRead == false && _unreadCount > 0) {
            _unreadCount--;
          }

          final updatedData = response.data['data'];
          if (updatedData != null) {
            _notifications[index] = NotificationModel.fromJson(updatedData);
          }
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      return false;
    }
  }

  // 4. Mark ALL Notifications As Read
  Future<bool> markAllAsRead() async {
    _setLoading(true);
    try {
      final response = await _apiClient.patch('/notifications/read-all');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Optimistically update all local notifications
        for (var i = 0; i < _notifications.length; i++) {
          if (_notifications[i].isRead == false) {
            _notifications[i] = NotificationModel(
              id: _notifications[i].id,
              userId: _notifications[i].userId,
              title: _notifications[i].title,
              message: _notifications[i].message,
              orderId: _notifications[i].orderId,
              order: _notifications[i].order,
              isRead: true, // Set to true
              createdAt: _notifications[i].createdAt,
              updatedAt: DateTime.now(),
            );
          }
        }
        _unreadCount = 0;
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint("Error marking all as read: $e");
      _setLoading(false);
      return false;
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
