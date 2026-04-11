import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/costum_viewmodel.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_screen.dart';
import '../costum/costum_detail_screen.dart';
import '../orders/order_detail_screen.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _notificationTimer;
  String? _selectedLokasi;
  int? _selectedAnimeId;
  int? _selectedBrandId;
  String _selectedOrderStatus = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationViewModel>(
        context,
        listen: false,
      ).fetchUnreadNotifications();
      Provider.of<CostumViewModel>(
        context,
        listen: false,
      ).fetchCostums(reset: true);
      Provider.of<CostumViewModel>(context, listen: false).fetchMasterData();
    });

    _scrollController.addListener(_onScroll);

    // Polling notifikasi setiap 1 menit
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        Provider.of<NotificationViewModel>(
          context,
          listen: false,
        ).fetchUnreadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Provider.of<CostumViewModel>(context, listen: false).fetchCostums(
      reset: true,
      search: _searchController.text,
      lokasi: _selectedLokasi,
      sourceAnimeCategoryId: _selectedAnimeId,
      brandCostumCategoryId: _selectedBrandId,
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _filterStartDate != null && _filterEndDate != null
        ? DateTimeRange(start: _filterStartDate!, end: _filterEndDate!)
        : null;

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B5226),
              onPrimary: Colors.white,
              onSurface: Color(0xFF3B5226),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _filterStartDate = pickedRange.start;
        _filterEndDate = pickedRange.end;
      });
      _fetchOrdersWithFilters();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate = null;
    });
    _fetchOrdersWithFilters();
  }

  void _fetchOrdersWithFilters() {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    orderVM.fetchOrders(
      status: _selectedOrderStatus.isEmpty ? null : _selectedOrderStatus,
      startDate: _filterStartDate != null
          ? DateFormat('yyyy-MM-dd').format(_filterStartDate!)
          : null,
      endDate: _filterEndDate != null
          ? DateFormat('yyyy-MM-dd').format(_filterEndDate!)
          : null,
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final vm = Provider.of<CostumViewModel>(context, listen: false);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filter Kostum',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLokasi,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi (Kota)',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Semua Lokasi'),
                      ),
                      ...vm.locations.map(
                        (loc) => DropdownMenuItem(value: loc, child: Text(loc)),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        _selectedLokasi = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedAnimeId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Anime',
                      prefixIcon: Icon(Icons.tv),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,

                        child: Text('Semua Anime'),
                      ),
                      ...vm.sourceAnimes.map(
                        (anime) => DropdownMenuItem(
                          value: anime.id,
                          child: Text(anime.name ?? 'Unknown'),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        _selectedAnimeId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedBrandId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Brand',
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Semua Brand'),
                      ),
                      ...vm.brands.map(
                        (brand) => DropdownMenuItem(
                          value: brand.id,
                          child: Text(brand.name ?? 'Unknown'),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        _selectedBrandId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    child: const Text('Terapkan Filter'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<CostumViewModel>(context, listen: false).loadNextPage();
    }
  }

  Future<void> _handleLogout() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.logout();

    if (mounted) {
      if (success || authVM.currentUser == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVM.errorMessage ?? 'Logout failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF9EAA78), // Top bar dark green
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 48), // Spacer for balance
              // Logo
              Expanded(
                child: Image.asset(
                  'assets/logo/logo-app.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Noctoriagoras\nCosrent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  },
                ),
              ),
              // Notifications
              Consumer<NotificationViewModel>(
                builder: (context, notifVM, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          ).then((_) {
                            Provider.of<NotificationViewModel>(
                              context,
                              listen: false,
                            ).fetchUnreadNotifications();
                          });
                        },
                      ),
                      if (notifVM.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${notifVM.unreadCount > 99 ? '99+' : notifVM.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<CostumViewModel>(
          context,
          listen: false,
        ).fetchCostums(reset: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Green Banner (Coming Soon)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF7CA66D), // Slightly darker green
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Center(
                    child: Text(
                      'COMING SOON',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Colors.white70),
                      SizedBox(width: 8),
                      Icon(Icons.circle, size: 10, color: Colors.white),
                      SizedBox(width: 8),
                      Icon(Icons.circle, size: 10, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Costum Terpopuler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kostum Terpopuler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B5226), // Dark green text
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2; // Navigasi ke Costum tab
                      });
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B5226),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Grid Kostum
            Consumer<CostumViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading && vm.costums.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (vm.errorMessage != null && vm.costums.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (vm.costums.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Belum ada kostum.'),
                    ),
                  );
                }

                final displayCostums = vm.costums.take(4).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.55, // Adjust for tall cards
                        ),
                    itemCount: displayCostums.length,
                    itemBuilder: (context, index) {
                      final costum = displayCostums[index];
                      return _buildCostumCard(costum);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCostumTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama kostum...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5226),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _applyFilters();
            },
            child: Consumer<CostumViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading && vm.costums.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.errorMessage != null && vm.costums.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (vm.costums.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada kostum di katalog.',
                      style: TextStyle(color: Color(0xFF3B5226)),
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: vm.costums.length + (vm.isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == vm.costums.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final costum = vm.costums[index];
                    return _buildCostumCard(costum);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostumCard(dynamic costum) {
    return GestureDetector(
      onTap: () {
        if (costum.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CostumDetailScreen(costumId: costum.id!),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCED8AF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3B5226), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14.5),
                ),
                child: costum.photoUrl != null
                    ? Image.network(
                        costum.photoUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Detail
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            costum.name?.toUpperCase() ?? 'UNKNOWN',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF3B5226),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.sell,
                                size: 14,
                                color: Color(0xFF3B5226),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  costum.brandCostumCategory?.name ?? 'Brand',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF3B5226),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.movie,
                                size: 14,
                                color: Color(0xFF3B5226),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  costum.nameAnime ?? 'Anime',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF3B5226),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color(0xFF3B5226),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  costum.lokasi?.toUpperCase() ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF3B5226),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFF3B5226), height: 8),
                    Text(
                      'Size : ${costum.size ?? '-'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF3B5226),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTab() {
    return Column(
      children: [
        // Dropdown Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7CA66D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOrderStatus,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    dropdownColor: const Color(0xFF7CA66D),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Semua Status')),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Menunggu'),
                      ),
                      DropdownMenuItem(value: 'paid', child: Text('Dibayar')),
                      DropdownMenuItem(value: 'done', child: Text('Selesai')),
                      DropdownMenuItem(
                        value: 'canceled',
                        child: Text('Dibatalkan'),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedOrderStatus = val ?? '';
                      });
                      _fetchOrdersWithFilters();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7CA66D),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _filterStartDate != null && _filterEndDate != null
                            ? '${DateFormat('dd/MM').format(_filterStartDate!)} - ${DateFormat('dd/MM').format(_filterEndDate!)}'
                            : 'Semua Tanggal',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (_filterStartDate != null)
                        GestureDetector(
                          onTap: _clearDateFilter,
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        )
                      else
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.black,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // List Transaksi
        Expanded(
          child: Consumer<OrderViewModel>(
            builder: (context, orderVM, child) {
              if (orderVM.isLoading && orderVM.orders.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B5226)),
                );
              }

              // Local filter untuk mengamankan jika API belum mendukung argumen status
              final filteredOrders = orderVM.orders.where((order) {
                if (_selectedOrderStatus.isEmpty) return true;
                return order.status?.toLowerCase() == _selectedOrderStatus;
              }).toList();

              if (filteredOrders.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada transaksi.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF3B5226)),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _fetchOrdersWithFilters(),
                color: const Color(0xFF3B5226),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];

                    // Format tanggal
                    String dateDisplay = '-';
                    if (order.createdAt != null &&
                        order.createdAt!.length >= 10) {
                      try {
                        final dt = DateTime.parse(order.createdAt!);
                        final months = [
                          'Januari',
                          'Februari',
                          'Maret',
                          'April',
                          'Mei',
                          'Juni',
                          'Juli',
                          'Agustus',
                          'September',
                          'Oktober',
                          'November',
                          'Desember',
                        ];
                        dateDisplay =
                            '${dt.day} ${months[dt.month - 1]} ${dt.year}';
                      } catch (_) {
                        dateDisplay = order.createdAt!.substring(0, 10);
                      }
                    }

                    String statusIndo = order.status ?? '-';
                    switch (order.status?.toLowerCase()) {
                      case 'pending':
                        statusIndo = 'Menunggu';
                        break;
                      case 'paid':
                        statusIndo = 'Dibayar';
                        break;
                      case 'done':
                        statusIndo = 'Selesai';
                        break;
                      case 'canceled':
                        statusIndo = 'Dibatalkan';
                        break;
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (order.id != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailScreen(orderId: order.id!),
                            ),
                          );
                          _fetchOrdersWithFilters();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCED8AF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF3B5226),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateDisplay,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B5226),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.codeBooking ?? '-',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF7CA66D),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7CA66D),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusIndo,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                              color: Color(0xFF3B5226),
                              thickness: 1,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Detail Transaksi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B5226),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (order.items != null)
                              ...order.items!.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '- ${item.costum?.name ?? 'Kostum'}',
                                          style: const TextStyle(
                                            color: Color(0xFF3B5226),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${item.costum?.priceday != null ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(item.costum!.priceday!) ?? 0) : '-'} x ${item.pcs ?? 1}',
                                        style: const TextStyle(
                                          color: Color(0xFF3B5226),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            const SizedBox(height: 12),
                            const Divider(
                              color: Color(0xFF3B5226),
                              thickness: 1,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Transaksi',
                                  style: TextStyle(
                                    color: Color(0xFF3B5226),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order.total != null
                                      ? NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(
                                          double.tryParse(order.total!) ?? 0,
                                        )
                                      : '-',
                                  style: const TextStyle(
                                    color: Color(0xFF3B5226),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFCED8AF), // Background color from mockup
      body: Column(
        children: [
          _buildTopBar(), // Sticky Top Bar
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // 0: Beranda
                _buildHomeTab(),

                // 1: Transaksi
                _buildTransactionTab(),

                // 2: Costum (Get All)
                _buildCostumTab(),

                // 3: Profil
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 100,
                        color: Color(0xFF3B5226),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Halo, ${user?.username ?? 'Member'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B5226),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFCED8AF),
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF35542E),
          unselectedItemColor: const Color(0xFF7CA66D),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            Provider.of<NotificationViewModel>(
              context,
              listen: false,
            ).fetchUnreadNotifications();

            if (index == 0) {
              final vm = Provider.of<CostumViewModel>(context, listen: false);
              vm.clearFilters();
              vm.fetchCostums(reset: true);
            } else if (index == 1) {
              Provider.of<OrderViewModel>(context, listen: false).fetchOrders();
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom),
              label: 'Kostum',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
