// pages/orders/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/models/PartnerModel.dart';
import 'package:smartfixTech/api_calls/models/order_model.dart';
// import 'package:smartfixTech/api_calls/models/partner_model.dart';
import 'package:smartfixTech/pages/home/home.dart';
import 'package:smartfixTech/pages/order/order_controller.dart';
import 'package:smartfixTech/pages/profile/widget/support_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final String orderNumber;

  OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  // Cache for icons and colors to prevent unnecessary recalculations
  final Map<String, IconData> _iconCache = {};
  final Map<String, Color> _colorCache = {};

  @override
  Widget build(BuildContext context) {
    final OrderController orderCtrl = Get.put(OrderController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            StreamBuilder<OrderModel?>(
              stream: orderCtrl.streamOrder(orderId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    'Status: ${snapshot.data!.statusText}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _getStatusColor(snapshot.data!.status),
                    ),
                  );
                }
                return Text(
                  orderNumber,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
          onPressed: () => Get.offAll(HomeScreen()),
        ),
        actions: [
          StreamBuilder<OrderModel?>(
            stream: orderCtrl.streamOrder(orderId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return PopupMenuButton<String>(
                  color: Colors.white,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                  onSelected: (value) async {
                    if (value == 'refresh') {
                      await orderCtrl.fetchOrderById(orderId);
                      Get.snackbar(
                        'Success',
                        'Order refreshed',
                        backgroundColor: Colors.white,
                        colorText: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else if (value == 'track') {
                      _showTrackingDialog(snapshot.data!);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 18),
                            SizedBox(width: 8),
                            Text('Refresh'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'track',
                        child: Row(
                          children: [
                            Icon(Icons.timeline, size: 18),
                            SizedBox(width: 8),
                            Text('Track Order'),
                          ],
                        ),
                      ),
                    ];
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Get.offAll(HomeScreen());
          return false;
        },
        child: StreamBuilder<OrderModel?>(
          stream: orderCtrl.streamOrder(orderId),
          builder: (context, snapshot) {
            // Handle connection state
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildShimmerLoading();
            }

            // Handle error
            if (snapshot.hasError) {
              return _buildErrorWidget(orderCtrl, snapshot.error);
            }

            // Handle no data
            if (!snapshot.hasData || snapshot.data == null) {
              return _buildErrorWidget(orderCtrl, null);
            }

            final order = snapshot.data!;

            // Clear caches when order updates to ensure fresh icons
            _iconCache.clear();
            _colorCache.clear();

            // Show loading indicator if data is being refreshed
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.hasData) {
              return Stack(
                children: [
                  _buildOrderDetails(order, orderCtrl),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.teal,
                      ),
                    ),
                  ),
                ],
              );
            }

            return _buildOrderDetails(order, orderCtrl);
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.white;
      case 'assigned':
        return Colors.white70;
      case 'on_the_way':
        return Colors.teal;
      case 'arrived':
        return Colors.white;
      case 'in_progress':
        return Colors.deepPurple;
      case 'completed':
        return Colors.white;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  void _showTrackingDialog(OrderModel order) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timeline,
                  color: Colors.teal.shade700,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Track Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...order.timeline.map(
                (timeline) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getTimelineColor(timeline.status),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getTimelineIcon(timeline.status),
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeline.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              timeline.formattedDateTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(OrderController orderCtrl, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Order Not Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error?.toString() ?? 'The order you\'re looking for doesn\'t exist',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildErrorButton(
                onPressed: () => Get.offAll(HomeScreen()),
                icon: Icons.home,
                label: 'Go Home',
                isPrimary: true,
              ),
              const SizedBox(width: 12),
              _buildErrorButton(
                onPressed: () => orderCtrl.fetchOrderById(orderId),
                icon: Icons.refresh,
                label: 'Retry',
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.teal : Colors.grey.shade200,
        foregroundColor: isPrimary ? Colors.white : Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isPrimary ? 2 : 0,
      ),
    );
  }

  Widget _buildOrderDetails(OrderModel order, OrderController orderCtrl) {
    return RefreshIndicator(
      onRefresh: () => orderCtrl.fetchOrderById(orderId),
      color: Colors.teal,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Order Summary Card
          _buildOrderSummaryCard(order, orderCtrl),
          const SizedBox(height: 16),

          // Timeline Section
          if (order.timeline.isNotEmpty) ...[
            _buildTimelineSection(order),
            const SizedBox(height: 16),
          ],

          // Delivery Address
          _buildAddressSection(order),
          const SizedBox(height: 16),

          // Payment Summary
          _buildPaymentSummary(order),
          const SizedBox(height: 16),

          // Action Buttons based on status
          _buildStatusBasedActions(order, orderCtrl),

          // Extra bottom padding for better scrolling
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Updated Order Summary Card with Partner Information
  Widget _buildOrderSummaryCard(OrderModel order, OrderController orderCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Number',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: 'Placed on',
                  value: order.formattedDate,
                ),
                const SizedBox(width: 16),
                if (order.expectedDelivery != null)
                  _buildInfoChip(
                    icon: Icons.delivery_dining,
                    label: 'Expected',
                    value: order.formattedExpectedDelivery!,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Assigned Technician Section (Keep existing)
            if (order.assignedTechnicianName != null &&
                order.assignedTechnicianName?.isNotEmpty == true) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assigned Technician',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          order.assignedTechnicianName!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // NEW: Partner Information Section - ONLY SHOW IF ORDER IS NOT COMPLETED
            // This will show if the order has a partnerId or partnerInfo AND status is NOT completed
            if (order.status != 'completed' && order.status != 'cancelled'&& order.status != 'pending' &&
                order.partnerId != null &&
                order.partnerId!.isNotEmpty) ...[
              const Divider(height: 24),
              const SizedBox(height: 8),
              FutureBuilder<PartnerModel?>(
                future: orderCtrl.fetchPartnerById(order.partnerId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildPartnerLoadingShimmer();
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _buildPartnerErrorWidget();
                  }
                  
                  final partner = snapshot.data!;
                  return _buildPartnerInfoCard(partner);
                },
              ),
            ],

            if (order.status == 'cancelled' &&
                order.cancellationReason != null) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cancellation Reason',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            order.cancellationReason!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
 void callCustomer(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
// Fixed Partner Info Card - No Overflow
Widget _buildPartnerInfoCard(PartnerModel partner) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.deepPurple.shade50,
          Colors.deepPurple.shade100.withOpacity(0.3),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.deepPurple.shade200,
        width: 1.5,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIXED: Use Row with Flexible to prevent overflow
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.business_center,
                size: 16,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(width: 8),
            // Use Flexible instead of direct Text to prevent overflow
            Flexible(
              child: Text(
                'Partner Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (partner.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner Photo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurple.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: partner.photoUrl.isNotEmpty
                    ? Image.network(
                        partner.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.deepPurple.shade100,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.deepPurple.shade400,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.deepPurple.shade100,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.deepPurple.shade400,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Partner Details - Use Expanded to take remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.deepPurple.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          partner.phoneNumber,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
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
        const SizedBox(height: 12),
        // Rating and Orders Count
        Row(
          children: [
            Icon(
              Icons.assignment,
              size: 14,
              color: Colors.deepPurple.shade600,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${partner.assignedOrdersCount} Orders',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Contact Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showPartnerContactDialog(partner);
            },
            icon: Icon(
              Icons.contact_support,
              size: 16,
              color: Colors.deepPurple.shade700,
            ),
            label: Text(
              'Contact Partner',
              style: TextStyle(
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: BorderSide(color: Colors.deepPurple.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  // Loading shimmer for partner info
  Widget _buildPartnerLoadingShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 16,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Error widget for partner info
  Widget _buildPartnerErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to load partner information',
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to show partner contact options
  void _showPartnerContactDialog(PartnerModel partner) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.contact_support,
                  size: 40,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Contact ${partner.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone, color: Colors.green.shade700),
                ),
                title: const Text('Call'),
                subtitle: Text(partner.phoneNumber),
                onTap: () {
                  callCustomer(partner.phoneNumber);
                  Get.back();
                },
              ),
              
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: order.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: order.statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(order.statusIcon, size: 14, color: order.statusColor),
          const SizedBox(width: 6),
          Text(
            order.statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: order.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: Colors.teal.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Order Timeline',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${order.timeline.length} updates',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ListView.separated(
              key: ValueKey(
                'timeline_${order.timeline.length}_${order.status}',
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.timeline.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final timeline = order.timeline[index];
                return _buildTimelineItem(timeline, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(dynamic timeline, int index) {
    // Get icon and color with caching for performance
    final icon = _getTimelineIconWithCache(timeline.status);
    final color = _getTimelineColorWithCache(timeline.status);

    return Row(
      key: ValueKey(
        'timeline_item_${index}_${timeline.status}_${timeline.timestamp}',
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade500,
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
                        Icons.person_outline,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'by ${timeline.performedBy}',
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
    );
  }

  // Cached methods for timeline icons and colors
  IconData _getTimelineIconWithCache(String status) {
    if (!_iconCache.containsKey(status)) {
      _iconCache[status] = _getTimelineIcon(status);
    }
    return _iconCache[status]!;
  }

  Color _getTimelineColorWithCache(String status) {
    if (!_colorCache.containsKey(status)) {
      _colorCache[status] = _getTimelineColor(status);
    }
    return _colorCache[status]!;
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
        return Icons.directions_bike_outlined;
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
        return Icons.info_outline;
    }
  }

  Color _getTimelineColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return const Color.fromARGB(255, 3, 74, 132);
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

  Widget _buildAddressSection(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.teal.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          order.address.icon,
                          size: 16,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          order.address.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.address.address,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Colors.teal.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.phone,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
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
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: Colors.teal.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildPaymentRow('Subtotal', order.subtotal),
                  _buildPaymentRow('Platform Fee', order.platformFee),
                  _buildPaymentRow('Shipping Fee', order.shippingFee),
                  if (order.gstAmount > 0)
                    _buildPaymentRow('GST', order.gstAmount),
                  if (order.discount > 0)
                    _buildPaymentRow(
                      'Discount',
                      -order.discount,
                      isDiscount: true,
                    ),
                  const Divider(height: 24, thickness: 1),
                  _buildPaymentRow(
                    'Total Amount',
                    order.totalAmount,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(
                  order.paymentStatus,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPaymentStatusColor(
                    order.paymentStatus,
                  ).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(
                        order.paymentStatus,
                      ).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPaymentStatusIcon(order.paymentStatus),
                      color: _getPaymentStatusColor(order.paymentStatus),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Status',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(
                        order.paymentStatus,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.formattedAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPaymentStatusColor(order.paymentStatus),
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
          Text(
            '${value < 0 ? '- ' : ''}₹${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.green
                  : (isTotal ? Colors.black87 : Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBasedActions(OrderModel order, OrderController orderCtrl) {
    List<Widget> actions = [];

    // Track order button (always show if there's timeline)
    if (order.timeline.isNotEmpty) {
      actions.add(
        _buildActionButton(
          onPressed: () => _showTrackingDialog(order),
          icon: Icons.timeline,
          label: 'Track Order',
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue.shade700,
          borderColor: Colors.blue.shade200,
        ),
      );
    }

    // Pending orders can be cancelled
    if (order.status == 'pending') {
      actions.add(
        _buildActionButton(
          onPressed: () => _showCancelDialog(order.orderId, orderCtrl),
          icon: Icons.cancel_outlined,
          label: 'Cancel Order',
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          borderColor: Colors.red.shade200,
        ),
      );
    }

    // All orders can contact support
    actions.add(
      _buildActionButton(
        onPressed: () => Get.to(() => SupportScreen()),
        icon: Icons.support_agent,
        label: 'Support',
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        hasBorder: false,
      ),
    );

    return Container(
      key: ValueKey(
        'actions_${order.status}_${order.timeline.length}',
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: actions.length > 2
                        ? (MediaQuery.of(Get.context!).size.width - 80) / 2
                        : double.infinity,
                    child: action,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusMessage(order.status),
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order is pending confirmation. You can cancel if needed.';
      case 'confirmed':
        return 'Your order has been confirmed. We\'re preparing it.';
      case 'assigned':
        return 'A technician has been assigned to your order.';
      case 'on_the_way':
        return 'Technician is on the way to your location.';
      case 'arrived':
        return 'Technician has arrived at your location.';
      case 'in_progress':
        return 'Work is in progress at your location.';
      case 'completed':
        return 'Order completed! Thank you for choosing us.';
      case 'cancelled':
        return 'This order has been cancelled.';
      default:
        return 'Order status: $status';
    }
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
    bool hasBorder = true,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasBorder
              ? BorderSide(color: borderColor ?? backgroundColor)
              : BorderSide.none,
        ),
        elevation: 0,
        minimumSize: const Size(double.infinity, 45),
      ),
    );
  }

  void _showCancelDialog(String orderId, OrderController orderCtrl) {
    final reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 40,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancel Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this order?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter cancellation reason...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keep Order',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (reasonController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please provide a reason for cancellation',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }

                        Get.back();
                        final success = await orderCtrl.cancelOrder(
                          orderId: orderId,
                          reason: reasonController.text.trim(),
                        );

                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Order cancelled successfully',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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