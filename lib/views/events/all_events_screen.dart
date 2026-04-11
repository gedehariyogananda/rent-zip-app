import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/event_viewmodel.dart';
import 'event_detail_screen.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _currentStatus = 'all'; // 'all' or 'archived'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventViewModel>(
        context,
        listen: false,
      ).fetchEvents(reset: true, status: _currentStatus);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<EventViewModel>(
        context,
        listen: false,
      ).loadNextPage(status: _currentStatus);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCED8AF),
      appBar: AppBar(
        title: const Text('Semua Event', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B5226),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _currentStatus = value;
              });
              Provider.of<EventViewModel>(
                context,
                listen: false,
              ).fetchEvents(reset: true, status: _currentStatus);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Akan Datang')),
              const PopupMenuItem(
                value: 'archived',
                child: Text('Riwayat / Selesai'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<EventViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.events.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B5226)),
            );
          }

          if (vm.errorMessage != null && vm.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Color(0xFF3B5226)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        vm.fetchEvents(reset: true, status: _currentStatus),
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

          if (vm.events.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada event saat ini.',
                style: TextStyle(fontSize: 16, color: Color(0xFF3B5226)),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF3B5226),
            onRefresh: () =>
                vm.fetchEvents(reset: true, status: _currentStatus),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: vm.events.length + (vm.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.events.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B5226),
                      ),
                    ),
                  );
                }

                final event = vm.events[index];
                return GestureDetector(
                  onTap: () {
                    if (event.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailScreen(eventId: event.id!),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child:
                              event.imageUrl != null &&
                                  event.imageUrl!.isNotEmpty
                              ? Image.network(
                                  event.imageUrl!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholderImage(),
                                )
                              : _buildPlaceholderImage(),
                        ),
                        // Event Details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.name ?? 'Unknown Event',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B5226),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: event.status == 'AVAILABLE'
                                          ? const Color(0xFF3B5226)
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      event.status == 'AVAILABLE'
                                          ? 'Akan Datang'
                                          : 'Selesai',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Color(0xFF7CA66D),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.formattedDate ?? event.date ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(0xFF7CA66D),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      event.location ?? '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFE8ECD7),
      child: const Center(
        child: Icon(Icons.event, size: 60, color: Color(0xFF9EAA78)),
      ),
    );
  }
}
