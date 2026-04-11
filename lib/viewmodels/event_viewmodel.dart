import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/event_model.dart';

class EventViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<EventModel> _events = [];
  EventModel? _selectedEvent;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMoreData = true;

  List<EventModel> get events => _events;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fetch paginated events
  Future<void> fetchEvents({
    bool reset = false,
    String status = 'all',
    int perPage = 10,
  }) async {
    if (reset) {
      _currentPage = 1;
      _events.clear();
      _hasMoreData = true;
      _setErrorMessage(null);
      _setLoading(true);
    } else {
      if (!_hasMoreData || _isLoadingMore) return;
      _setLoadingMore(true);
    }

    try {
      final queryParams = <String, dynamic>{
        'page': _currentPage,
        'per_page': perPage,
      };

      if (status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        '/events',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final newEvents = data
            .map((json) => EventModel.fromJson(json))
            .toList();

        if (reset) {
          _events = newEvents;
        } else {
          _events.addAll(newEvents);
        }

        final meta = response.data['meta'];
        if (meta != null) {
          _currentPage = meta['current_page'] ?? 1;
          _lastPage = meta['last_page'] ?? 1;
          _hasMoreData = _currentPage < _lastPage;
        } else {
          _hasMoreData = false;
        }
      } else {
        _setErrorMessage(response.data['message'] ?? 'Failed to fetch events');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      if (reset) {
        _setLoading(false);
      } else {
        _setLoadingMore(false);
      }
    }
  }

  // Load next page
  Future<void> loadNextPage({String status = 'all', int perPage = 10}) async {
    if (_hasMoreData && !_isLoading && !_isLoadingMore) {
      _currentPage++;
      await fetchEvents(reset: false, status: status, perPage: perPage);
    }
  }

  // Fetch single event detail
  Future<void> fetchEventDetail(int id) async {
    _setLoading(true);
    _setErrorMessage(null);
    _selectedEvent = null;

    try {
      final response = await _apiClient.get('/events/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          _selectedEvent = EventModel.fromJson(data);
        }
      } else {
        _setErrorMessage(response.data['message'] ?? 'Event not found');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setErrorMessage(e.toString());
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
