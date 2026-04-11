import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/costum_viewmodel.dart';
import 'package:intl/intl.dart';

class CostumDetailScreen extends StatefulWidget {
  final int costumId;

  const CostumDetailScreen({super.key, required this.costumId});

  @override
  State<CostumDetailScreen> createState() => _CostumDetailScreenState();
}

class _CostumDetailScreenState extends State<CostumDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CostumViewModel>(
        context,
        listen: false,
      ).fetchCostumDetail(widget.costumId);
    });
  }

  String _formatCurrency(int? price) {
    if (price == null) return 'Rp 0';
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF3B5226);
    final bgColor = const Color(0xFFCED8AF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<CostumViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B5226)),
            );
          }

          if (vm.errorMessage != null && vm.selectedCostum == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchCostumDetail(widget.costumId),
                    style: ElevatedButton.styleFrom(backgroundColor: textColor),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final costum = vm.selectedCostum;
          if (costum == null) {
            return Center(
              child: Text(
                'Kostum tidak ditemukan.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Image Header with SliverAppBar
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                backgroundColor: textColor,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      costum.photoUrl != null && costum.photoUrl!.isNotEmpty
                          ? Image.network(
                              costum.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                      // Gradient for smooth transition
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [bgColor, bgColor.withOpacity(0.0)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Anime Tag & Title
                      Row(
                        children: [
                          Icon(Icons.movie, size: 16, color: textColor),
                          const SizedBox(width: 8),
                          Text(
                            costum.nameAnime ?? 'Anime',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        costum.name?.toUpperCase() ?? 'UNKNOWN COSTUM',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price & Size Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_formatCurrency(costum.priceday)} / 3 Hari',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: textColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Size: ${costum.size ?? '-'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info Grid Details
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: textColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(
                                  Icons.location_on,
                                  'Lokasi',
                                  costum.lokasi ?? '-',
                                  textColor,
                                ),
                                _buildInfoItem(
                                  Icons.sell,
                                  'Brand',
                                  costum.brandCostumCategory?.name ?? '-',
                                  textColor,
                                ),
                                _buildInfoItem(
                                  Icons.inventory,
                                  'Stok',
                                  '${costum.availableStock ?? 0}',
                                  textColor,
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(
                                  Icons.person,
                                  'Cosplayer',
                                  costum.namaCosplayer ?? '-',
                                  textColor,
                                ),
                                _buildInfoItem(
                                  Icons.local_shipping,
                                  'Paxel',
                                  costum.paxel ?? '-',
                                  textColor,
                                ),
                                _buildInfoItem(
                                  Icons.scale,
                                  'Berat',
                                  '${costum.beratJnt ?? 0} Kg',
                                  textColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Description
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: textColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          costum.desc ?? 'Tidak ada deskripsi.',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.9),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // padding for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CostumViewModel>(
        builder: (context, vm, child) {
          final costum = vm.selectedCostum;
          if (costum == null) return const SizedBox.shrink();

          final isAvailable = (costum.availableStock ?? 0) > 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: textColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: true,
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: isAvailable
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Sewa segera hadir!'),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? textColor : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          isAvailable ? 'Sewa Sekarang' : 'Stok Habis',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
