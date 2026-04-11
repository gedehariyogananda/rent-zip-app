import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(
        context,
        listen: false,
      ).fetchOrderById(widget.orderId);
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '-';
    return dateStr.substring(0, 10);
  }

  String _formatStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'paid':
        return 'Dibayar';
      case 'done':
        return 'Selesai';
      case 'canceled':
        return 'Dibatalkan';
      default:
        return status?.toUpperCase() ?? '-';
    }
  }

  String _formatCurrency(String? amount) {
    if (amount == null) return '-';
    final val = double.tryParse(amount) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCED8AF),
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3B5226),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderVM, child) {
          if (orderVM.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B5226)),
            );
          }

          if (orderVM.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    orderVM.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderVM.fetchOrderById(widget.orderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5226),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final order = orderVM.selectedOrder;

          if (order == null) {
            return const Center(
              child: Text(
                'Pesanan tidak ditemukan.',
                style: TextStyle(fontSize: 16, color: Color(0xFF3B5226)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECD7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B5226),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('No. Pesanan', order.codeBooking ?? '-'),
                      const Divider(color: Color(0xFF3B5226), thickness: 0.5),
                      _buildInfoRow('Status', _formatStatus(order.status)),
                      const Divider(color: Color(0xFF3B5226), thickness: 0.5),
                      if (order.status?.toLowerCase() == 'pending') ...[
                        _buildQrisRow(context, order),
                        const Divider(color: Color(0xFF3B5226), thickness: 0.5),
                      ],
                      _buildInfoRow(
                        'Tanggal Mulai',
                        _formatDate(order.tglSewa),
                      ),
                      const Divider(color: Color(0xFF3B5226), thickness: 0.5),
                      _buildInfoRow(
                        'Tanggal Selesai',
                        _formatDate(order.tglPengembalian),
                      ),
                      const Divider(color: Color(0xFF3B5226), thickness: 0.5),
                      _buildInfoRow(
                        'Total Harga',
                        _formatCurrency(order.total),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Items Section
                const Text(
                  'Item Pesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B5226),
                  ),
                ),
                const SizedBox(height: 12),

                if (order.items != null && order.items!.isNotEmpty)
                  ...order.items!.map((item) {
                    final costum = item.costum;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF3B5226),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8ECD7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: costum?.photoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      costum!.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.checkroom,
                                    color: Color(0xFF3B5226),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  costum?.name ?? 'Unknown Item',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B5226),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Size: ${costum?.size ?? '-'}  |  Qty: ${item.pcs ?? 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7CA66D),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatCurrency(costum?.priceday),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B5226),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                if (order.items == null || order.items!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada item.'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrisRow(BuildContext context, dynamic order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'QRIS Pembayaran',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF3B5226),
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final authVm = Provider.of<AuthViewModel>(context, listen: false);
              final orderVm = Provider.of<OrderViewModel>(
                context,
                listen: false,
              );

              final isVerified = await authVm.checkProfile();

              if (!context.mounted) return;

              if (isVerified == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Silakan lengkapi profil Anda di pengaturan profil terlebih dahulu.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final qrisUrl = await orderVm.getStaticQris();

              if (!context.mounted) return;

              if (qrisUrl != null && qrisUrl.isNotEmpty) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Pembayaran QRIS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B5226),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Silakan scan QRIS dan bayar sesuai nominal yaitu ${_formatCurrency(order.total)}. Lalu nanti konfirmasi pesanan akan diarahkan ke WhatsApp, silakan sekalian lampirkan bukti foto transfer ya.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF3B5226),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.network(
                            qrisUrl,
                            height: 250,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF3B5226),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (c, e, s) => const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('Gagal memuat QRIS'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF3B5226),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Tutup',
                                  style: TextStyle(
                                    color: Color(0xFF3B5226),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: const Color(0xFF3B5226),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final message =
                                      'Halo Admin Noctoriagoras, saya sudah membayar pesanan dengan Kode Booking: ${order.codeBooking ?? '-'} senilai ${_formatCurrency(order.total)}. Berikut saya lampirkan bukti foto transfernya. Mohon segera dikonfirmasi. Terima kasih!';
                                  final url = Uri.parse(
                                    'whatsapp://send?phone=${AppConstants.whatsappNumber}&text=${Uri.encodeComponent(message)}',
                                  );
                                  final fallbackUrl = Uri.parse(
                                    'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(message)}',
                                  );
                                  try {
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      await launchUrl(
                                        fallbackUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  } catch (_) {
                                    try {
                                      await launchUrl(
                                        fallbackUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Gagal membuka WhatsApp',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  'Konfirmasi Pembayaran',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gambar QRIS belum tersedia')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B5226),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Lihat QRIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3B5226),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF3B5226),
            ),
          ),
        ],
      ),
    );
  }
}
