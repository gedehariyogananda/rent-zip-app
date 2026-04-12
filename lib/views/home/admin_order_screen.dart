import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/admin_order_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../notifications/notification_screen.dart';
import '../orders/order_detail_screen.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedOrderStatus = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  final Color _bgColor = const Color(0xFFCED8AF);
  final Color _primaryColor = const Color(0xFF3B5226);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrdersWithFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrdersWithFilters() async {
    await Provider.of<AdminOrderViewModel>(context, listen: false).fetchOrders(
      status: _selectedOrderStatus.isEmpty ? null : _selectedOrderStatus,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      startDate: _filterStartDate != null
          ? DateFormat('yyyy-MM-dd').format(_filterStartDate!)
          : null,
      endDate: _filterEndDate != null
          ? DateFormat('yyyy-MM-dd').format(_filterEndDate!)
          : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, notifVM, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
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
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
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
      body: Column(
        children: [
          // Filter Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Kode Booking...',
                    hintStyle: TextStyle(color: _primaryColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: _primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  onSubmitted: (_) => _fetchOrdersWithFilters(),
                ),
                const SizedBox(height: 12),
                // Dropdown Filter & Date Picker
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                            isExpanded: true,
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
                              DropdownMenuItem(
                                value: '',
                                child: Text('Semua Status'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Menunggu'),
                              ),
                              DropdownMenuItem(
                                value: 'paid',
                                child: Text('Dibayar'),
                              ),
                              DropdownMenuItem(
                                value: 'done',
                                child: Text('Selesai'),
                              ),
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
              ],
            ),
          ),

          // List Transaksi
          Expanded(
            child: Consumer<AdminOrderViewModel>(
              builder: (context, orderVM, child) {
                if (orderVM.isLoading && orderVM.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B5226)),
                  );
                }

                if (orderVM.orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada transaksi ditemukan.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3B5226),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    Provider.of<NotificationViewModel>(
                      context,
                      listen: false,
                    ).fetchUnreadNotifications();
                    await _fetchOrdersWithFilters();
                  },
                  color: const Color(0xFF3B5226),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orderVM.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderVM.orders[index];

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
      ),
    );
  }
}
