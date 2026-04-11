import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/costum_model.dart';

class CostumViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<CostumModel> _costums = [];
  CostumModel? _selectedCostum;

  List<CategoryModel> _sourceAnimes = [];
  List<CategoryModel> _brands = [];
  List<String> _locations = [];

  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMoreData = true;

  // Active Filters
  String? _activeSearch;
  String? _activeLokasi;
  int? _activeSourceAnimeCategoryId;
  int? _activeBrandCostumCategoryId;

  List<CostumModel> get costums => _costums;
  CostumModel? get selectedCostum => _selectedCostum;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  List<CategoryModel> get sourceAnimes => _sourceAnimes;
  List<CategoryModel> get brands => _brands;
  List<String> get locations => _locations;

  void clearFilters() {
    _activeSearch = null;
    _activeLokasi = null;
    _activeSourceAnimeCategoryId = null;
    _activeBrandCostumCategoryId = null;
    // We don't notifyListeners here since we usually call fetchCostums right after
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    _isFetchingMore = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 1. Get All Costums (With Pagination & Filters)
  Future<void> fetchCostums({
    bool reset = false,
    String? search,
    String? lokasi,
    int? sourceAnimeCategoryId,
    int? brandCostumCategoryId,
  }) async {
    if (reset) {
      _currentPage = 1;
      _costums.clear();
      _hasMoreData = true;
      _activeSearch = search;
      _activeLokasi = lokasi;
      _activeSourceAnimeCategoryId = sourceAnimeCategoryId;
      _activeBrandCostumCategoryId = brandCostumCategoryId;
      _setErrorMessage(null);
      _setLoading(true);
    } else {
      if (!_hasMoreData || _isFetchingMore) return;
      _setFetchingMore(true);
    }

    try {
      final queryParams = <String, dynamic>{
        'page': _currentPage,
        'per_page': 10,
      };

      if (_activeSearch != null && _activeSearch!.isNotEmpty) {
        queryParams['search'] = _activeSearch;
      }
      if (_activeLokasi != null && _activeLokasi!.isNotEmpty) {
        queryParams['lokasi'] = _activeLokasi;
      }
      if (_activeSourceAnimeCategoryId != null) {
        queryParams['source_anime_category_id'] = _activeSourceAnimeCategoryId;
      }
      if (_activeBrandCostumCategoryId != null) {
        queryParams['brand_costum_category_id'] = _activeBrandCostumCategoryId;
      }

      final response = await _apiClient.get(
        '/costums',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        List<dynamic> items = [];
        if (data is List) {
          items = data;
        } else if (data != null && data['data'] is List) {
          items = data['data'];
        }

        final newCostums = items
            .map((json) => CostumModel.fromJson(json))
            .toList();

        if (reset) {
          _costums = newCostums;
        } else {
          _costums.addAll(newCostums);
        }

        if (data is Map<String, dynamic> && data.containsKey('current_page')) {
          _currentPage = data['current_page'] ?? 1;
          _lastPage = data['last_page'] ?? 1;
          _hasMoreData = _currentPage < _lastPage;
        } else {
          _hasMoreData = false;
        }
      } else {
        if (reset)
          _setErrorMessage(
            response.data['message'] ?? 'Failed to fetch costumes',
          );
      }
    } on DioException catch (e) {
      if (reset) _handleDioError(e);
    } catch (e) {
      if (reset) _setErrorMessage(e.toString());
    } finally {
      if (reset) {
        _setLoading(false);
      } else {
        _setFetchingMore(false);
      }
    }
  }

  // Load Next Page
  Future<void> loadNextPage() async {
    if (_hasMoreData && !_isLoading && !_isFetchingMore) {
      _currentPage++;
      await fetchCostums(reset: false);
    }
  }

  // Fetch Master Data (Filters)
  Future<void> fetchMasterData() async {
    try {
      final resAnime = await _apiClient.get('/categories/source-animes');
      if (resAnime.statusCode == 200 && resAnime.data['success'] == true) {
        final List<dynamic> data = resAnime.data['data'] ?? [];
        _sourceAnimes = data.map((e) => CategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching source-animes: $e");
    }

    try {
      final resBrand = await _apiClient.get('/categories/brands');
      if (resBrand.statusCode == 200 && resBrand.data['success'] == true) {
        final List<dynamic> data = resBrand.data['data'] ?? [];
        _brands = data.map((e) => CategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching brands: $e");
    }

    try {
      final resLoc = await _apiClient.get('/locations');
      if (resLoc.statusCode == 200 && resLoc.data['success'] == true) {
        final List<dynamic> data = resLoc.data['data'] ?? [];
        _locations = data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
    }

    notifyListeners();
  }

  // 2. Get Detail Costum
  Future<void> fetchCostumDetail(int id) async {
    _setLoading(true);
    _setErrorMessage(null);
    _selectedCostum = null;

    try {
      final response = await _apiClient.get('/costums/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          _selectedCostum = CostumModel.fromJson(data);
        }
      } else {
        _setErrorMessage(response.data['message'] ?? 'Costume not found');
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
