import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../../profile/complete_profile_screen.dart';
import '../../orders/order_detail_screen.dart';

class RentBottomSheet extends StatefulWidget {
  final int costumId;
  final int maxStock;
  final int pricePer3Days;

  const RentBottomSheet({
    super.key,
    required this.costumId,
    required this.maxStock,
    required this.pricePer3Days,
  });

  @override
  State<RentBottomSheet> createState() => _RentBottomSheetState();
}

class _RentBottomSheetState extends State<RentBottomSheet> {
  int _quantity = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final Color _textColor = const Color(0xFF3B5226);
  final Color _bgColor = const Color(0xFFCED8AF);

  String _formatCurrency(int price) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDate = DateTime.now().add(const Duration(days: 1));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: initialDate,
              end: initialDate.add(const Duration(days: 2)),
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _textColor,
              onPrimary: Colors.white,
              onSurface: _textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      DateTime start = picked.start;
      DateTime end = picked.end;

      int totalDays = end.difference(start).inDays + 1;
      int remainder = totalDays % 3;

      if (remainder != 0) {
        totalDays = totalDays + (3 - remainder);
        end = start.add(Duration(days: totalDays - 1));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Durasi sewa otomatis disesuaikan menjadi kelipatan 3 hari ($totalDays hari).',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      setState(() {
        _startDate = start;
        _endDate = end;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal sewa terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final orderVm = Provider.of<OrderViewModel>(context, listen: false);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    final result = await orderVm.createOrder(
      widget.costumId,
      _quantity,
      formatter.format(_startDate!),
      formatter.format(_endDate!),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success'] == true) {
      final orderId = result['order_id'];
      final navigator = Navigator.of(context);
      navigator.pop(); // Close bottom sheet first

      if (result['verified'] == false) {
        // Navigate to Complete Profile, and wait for result
        navigator
            .push(
              MaterialPageRoute(
                builder: (context) => const CompleteProfileScreen(),
              ),
            )
            .then((success) {
              // If profile completion returns true, automatically go to Order Detail
              if (success == true && orderId != null) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(orderId: orderId),
                  ),
                );
              }
            });
      } else {
        // Success and verified, navigate to Order Detail
        if (orderId != null) {
          navigator.push(
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: orderId),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderVm.errorMessage ?? 'Gagal membuat pesanan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = widget.pricePer3Days * _quantity;

    // Calculate total days if dates are selected
    int totalDays = 3; // Default minimum
    if (_startDate != null && _endDate != null) {
      totalDays = _endDate!.difference(_startDate!).inDays + 1;
    }

    // Just a simple logic for total price based on 3-day blocks, can be adjusted based on exact API logic
    final int calculatedPrice = (totalPrice * (totalDays / 3).ceil()).toInt();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Atur Sewa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                color: _textColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Picker
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Tanggal Sewa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '(Wajib kelipatan 3 hari)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDateRange(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _textColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: _textColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                          : 'Pilih Tanggal Sewa',
                      style: TextStyle(
                        fontSize: 16,
                        color: _startDate != null ? _textColor : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah (Pcs)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: _textColor,
                  ),
                  Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < widget.maxStock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: _textColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sisa stok: ${widget.maxStock}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const Divider(height: 32),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga',
                style: TextStyle(fontSize: 16, color: _textColor),
              ),
              Text(
                _formatCurrency(calculatedPrice),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        fontSize: 16,
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
}
