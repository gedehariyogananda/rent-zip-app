import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_order_viewmodel.dart';

class AdminQrisScreen extends StatefulWidget {
  const AdminQrisScreen({super.key});

  @override
  State<AdminQrisScreen> createState() => _AdminQrisScreenState();
}

class _AdminQrisScreenState extends State<AdminQrisScreen> {
  String? _qrisUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQris();
  }

  Future<void> _fetchQris() async {
    final viewModel = Provider.of<AdminOrderViewModel>(context, listen: false);
    final url = await viewModel.getStaticQris();

    if (mounted) {
      setState(() {
        _qrisUrl = url;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFCED8AF,
      ), // Background color from member dashboard mockup
      appBar: AppBar(
        title: const Text(
          'QRIS Pembayaran',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(
          0xFF3B5226,
        ), // Member dashboard theme color
        foregroundColor: Colors.white, // White text
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF3B5226))
              : _qrisUrl != null
              ? Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Scan QRIS untuk Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5226),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _qrisUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                )
              : const Text(
                  'Gagal memuat QRIS',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
