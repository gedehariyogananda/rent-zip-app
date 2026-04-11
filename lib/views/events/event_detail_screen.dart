import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/event_viewmodel.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventViewModel>(
        context,
        listen: false,
      ).fetchEventDetail(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF3B5226);
    final bgColor = const Color(0xFFCED8AF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<EventViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B5226)),
            );
          }

          if (vm.errorMessage != null && vm.selectedEvent == null) {
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
                    onPressed: () => vm.fetchEventDetail(widget.eventId),
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

          final event = vm.selectedEvent;
          if (event == null) {
            return Center(
              child: Text(
                'Event tidak ditemukan.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: textColor,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: event.status == 'AVAILABLE'
                              ? textColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.status == 'AVAILABLE'
                              ? 'Akan Datang'
                              : 'Selesai',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        event.name ?? 'Unknown Event',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.calendar_month,
                              'Tanggal',
                              event.formattedDate ?? event.date ?? '-',
                              textColor,
                            ),
                            const Divider(height: 32),
                            _buildInfoRow(
                              Icons.location_on,
                              'Lokasi',
                              event.location ?? '-',
                              textColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8ECD7),
      child: const Center(
        child: Icon(Icons.event, size: 80, color: Color(0xFF9EAA78)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
