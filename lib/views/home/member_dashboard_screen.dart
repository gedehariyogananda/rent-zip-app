import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/costum_viewmodel.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_screen.dart';
import '../costum/costum_detail_screen.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLokasi;
  int? _selectedAnimeId;
  int? _selectedBrandId;

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
  }

  @override
  void dispose() {
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
                          color: Colors.white,
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
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
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 100,
                        color: Color(0xFF3B5226),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Halaman Transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF3B5226),
                        ),
                      ),
                    ],
                  ),
                ),

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
            if (index == 0) {
              final vm = Provider.of<CostumViewModel>(context, listen: false);
              vm.clearFilters();
              vm.fetchCostums(reset: true);
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
