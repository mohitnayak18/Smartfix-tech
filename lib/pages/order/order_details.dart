// pages/orders/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/api_calls/models/order_model.dart';
import 'package:smartfixapp/pages/home/home.dart';
import 'package:smartfixapp/pages/order/order_controller.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Use Get.find to get the existing controller instance
    final OrderController orderCtrl = Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAll(HomeScreen()),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              orderCtrl.fetchOrderById(orderId);
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadOrderDetails(orderCtrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          return StreamBuilder<OrderModel?>(
            stream: orderCtrl.streamOrder(orderId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return _buildErrorWidget(orderCtrl);
              }

              final order = snapshot.data!;
              return _buildOrderDetails(order, orderCtrl);
            },
          );
        },
      ),
    );
  }

  Future<void> _loadOrderDetails(OrderController orderCtrl) async {
    // Load order details when screen opens
    await orderCtrl.fetchOrderById(orderId);
  }

  Widget _buildErrorWidget(OrderController orderCtrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
            'Order not found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.offAll(HomeScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('Go to Home'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => orderCtrl.fetchOrderById(orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(OrderModel order, OrderController orderCtrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          _buildOrderSummaryCard(order),
          const SizedBox(height: 16),

          // Timeline Section
          if (order.timeline.isNotEmpty) ...[
            _buildTimelineSection(order),
            const SizedBox(height: 16),
          ],

          // Items Section
          _buildItemsSection(order),
          const SizedBox(height: 16),

          // Delivery Address
          _buildAddressSection(order),
          const SizedBox(height: 16),

          // Payment Summary
          _buildPaymentSummary(order),
          const SizedBox(height: 16),

          // Action Buttons
          if (order.status == 'pending') _buildActionButtons(order, orderCtrl),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: order.statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        order.statusIcon,
                        size: 16,
                        color: order.statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order.statusText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: order.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Placed on ${order.formattedDate}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (order.expectedDelivery != null)
              Row(
                children: [
                  Icon(
                    Icons.delivery_dining,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Expected: ${order.formattedExpectedDelivery}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

            if (order.assignedTechnicianName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Technician: ${order.assignedTechnicianName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (order.status == 'cancelled' &&
                order.cancellationReason != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.cancel, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: ${order.cancellationReason}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Order Timeline',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              children: order.timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final timeline = entry.value;
                final isLast = index == order.timeline.length - 1;

                return Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getTimelineColor(timeline.status),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              _getTimelineIcon(timeline.status),
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeline.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeline.formattedDateTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              if (timeline.performedBy != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'By: ${timeline.performedBy}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  order.itemCountText,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              children: order.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.build, color: Colors.teal),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (item.serviceType != null)
                              Text(
                                item.serviceType!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.teal.shade600,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity} x ${item.formattedPrice}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  item.formattedTotal,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(order.address.icon, color: Colors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.address.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.address.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              children: [
                _buildPaymentRow('Subtotal', order.subtotal),
                _buildPaymentRow('Platform Fee', order.platformFee),
                _buildPaymentRow('Shipping Fee', order.shippingFee),
                if (order.gstAmount > 0)
                  _buildPaymentRow('GST & Charges', order.gstAmount),
                if (order.discount > 0)
                  _buildPaymentRow(
                    'Discount',
                    -order.discount,
                    isDiscount: true,
                  ),
                const Divider(height: 20),
                _buildPaymentRow(
                  'Total Amount',
                  order.totalAmount,
                  isTotal: true,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(
                  order.paymentStatus,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getPaymentStatusColor(order.paymentStatus),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(order.paymentStatus),
                    color: _getPaymentStatusColor(order.paymentStatus),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _getPaymentStatusText(order.paymentStatus),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getPaymentStatusColor(order.paymentStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    order.formattedAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    double value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '${value < 0 ? '-' : ''}₹${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.green : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, OrderController orderCtrl) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showCancelDialog(order.orderId, orderCtrl),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Support',
                'Contact support at: support@smartfixapp.com',
                backgroundColor: Colors.teal,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(String orderId, OrderController orderCtrl) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please provide a reason',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              final success = await orderCtrl.cancelOrder(
                orderId: orderId,
                reason: reasonController.text.trim(),
              );

              if (success) {
                Get.back(); // Go back to orders list
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  // Helper methods for timeline
  Color _getTimelineColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'assigned':
        return Colors.indigo;
      case 'on_the_way':
        return Colors.teal;
      case 'arrived':
        return Colors.lightBlue;
      case 'in_progress':
        return Colors.deepPurple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'payment_updated':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTimelineIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'assigned':
        return Icons.person_add;
      case 'on_the_way':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'payment_updated':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  // Helper methods for payment status
  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
