// pages/orders/orders_list_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/models/order_model.dart';
import 'package:smartfixTech/pages/order/order_details.dart';
import 'package:smartfixTech/pages/order/order_controller.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final OrderController orderCtrl = Get.put(OrderController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load orders when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    try {
      // Get current user ID - IMPORTANT: You need to get this from your auth system
      // For now, using a placeholder. Replace with actual auth user ID
      String userId = _getCurrentUserId();
      await orderCtrl.fetchUserOrders(userId);
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  String _getCurrentUserId() {
    // TODO: Replace with your actual authentication user ID
    // This should come from Firebase Auth or your auth provider
    // Example:
    return FirebaseAuth.instance.currentUser?.uid ?? 'default_user_id';

    // For testing, return a test user ID
    // return 'test_user_id_123'; // Replace with actual auth user ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadOrders();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (orderCtrl.isLoading.value && orderCtrl.orders.isEmpty) {
          return _buildLoadingIndicator();
        }

        if (orderCtrl.error.value.isNotEmpty && orderCtrl.orders.isEmpty) {
          return _buildErrorView();
        }

        final orders = orderCtrl.orders;

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return _buildOrdersList(orders);
      }),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.teal));
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              orderCtrl.error.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async => await _loadOrders(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When you place orders, they will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            child: const Text('Browse Services'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadOrders();
        return;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderListCard(order: order);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class OrderListCard extends StatelessWidget {
  final OrderModel order;

  const OrderListCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.to(
            () => OrderDetailsScreen(
              orderId: order.orderId,
              orderNumber: order.orderNumber,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header with number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(order.status),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          size: 12,
                          color: _getStatusColor(order.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(order.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Order date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(order.createdAt.toDate()),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),

              // Items list (show first 2 items)
              ...order.items.take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatCurrency(item.total),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Show more items indicator
              if (order.items.length > 2) ...[
                const SizedBox(height: 2),
                Text(
                  '+ ${order.items.length - 2} more items',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Total amount and view details button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatCurrency(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => OrderDetailsScreen(
                          orderId: order.orderId,
                          orderNumber: order.orderNumber,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                      foregroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.teal.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for status display
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'assigned':
        return Colors.indigo;
      case 'on_the_way':
        return Colors.blueAccent;
      case 'arrived':
        return Colors.cyan;
      case 'in_progress':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.refresh;
      case 'assigned':
        return Icons.person_add;
      case 'on_the_way':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    final statusMap = {
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'processing': 'Processing',
      'assigned': 'Assigned',
      'on_the_way': 'On the way',
      'arrived': 'Arrived',
      'in_progress': 'In progress',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    };
    return statusMap[status] ?? status;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
