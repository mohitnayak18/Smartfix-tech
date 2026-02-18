import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';

import 'package:smartfixTech/pages/cart/widget/adress_widget.dart';
import 'package:smartfixTech/pages/cart/widget/checkout_bar.dart';
import 'package:smartfixTech/pages/order/order.dart';

// ==================== CONSTANTS & STYLES ====================
const _appBarTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Colors.white,
  letterSpacing: 0.5,
);

const _sectionTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: Colors.black87,
  letterSpacing: 0.5,
);

// ==================== CART VIEW ====================
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(cartCtrl),
      body: SafeArea(child: _buildBody(cartCtrl)),
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(CartController cartCtrl) {
    return AppBar(
      title: _buildAppBarTitle(),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: [
        // View Saved Carts Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
            onPressed: () {
              cartCtrl.clearCart();

              // Get.to(() => const SavedCartsPage());
            },

            //tooltip: 'Delete all from Carts',
            splashRadius: 20,
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_cart, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Obx(() {
          final itemCount = Get.find<CartController>().cartItems.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("My Cart", style: _appBarTitleStyle),
              Text(
                "$itemCount ${itemCount == 1 ? 'item' : 'items'}",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ==================== BODY ====================
  Widget _buildBody(CartController cartCtrl) {
    return Obx(() {
      if (cartCtrl.isLoading.value) return _buildLoadingState();
      if (cartCtrl.cartItems.isEmpty) return _buildEmptyState();
      return _buildCartContent(cartCtrl);
    });
  }

  Widget _buildCartContent(CartController cartCtrl) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              try {
                await cartCtrl.loadCartFromFirebase();
              } catch (e) {
                Get.snackbar(
                  'Refresh Failed',
                  'Unable to refresh cart',
                  backgroundColor: Colors.white,
                  colorText: Colors.red,
                );
              }
            },
            color: Colors.teal,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildCartSummary(cartCtrl),
                _buildCartItemsTitle(),
                _buildCartItemsList(cartCtrl),
                _buildAddressTitle(),
                _buildAddressSection(cartCtrl),
                _buildCheckoutSection(cartCtrl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SLIVER WIDGETS ====================
  SliverToBoxAdapter _buildCartSummary(CartController cartCtrl) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.teal.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cart Summary",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal, Colors.teal.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(() {
                    return Text(
                      "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  size: 16,
                  color: Colors.teal.shade600,
                ),
                const SizedBox(width: 2, height: 2),
                Obx(
                  () => Text(
                    "${cartCtrl.cartItems.length} items",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    "₹${NumberFormat('#,##0').format(cartCtrl.subtotal.value)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color.fromARGB(255, 137, 0, 130),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Obx(() {
              if (cartCtrl.discount.value > 0) {
                return Row(
                  children: [
                    Icon(
                      Icons.discount_rounded,
                      size: 16,
                      color: Colors.teal.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Discount: -₹${NumberFormat('#,##0').format(cartCtrl.discount.value)}",
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCartItemsTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Items",
              style: _sectionTitleStyle.copyWith(color: Colors.grey.shade800),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Obx(() {
                final itemCount = Get.find<CartController>().cartItems.length;
                return Text(
                  "$itemCount items",
                  style: TextStyle(
                    color: Colors.teal.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildCartItemsList(CartController cartCtrl) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = cartCtrl.cartItems[index];
          return Container(
            margin: EdgeInsets.fromLTRB(12, index == 0 ? 0 : 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item header with service details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Service image/icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          item.image,
                          fit: BoxFit.contain,
                          cacheHeight: 100,
                          cacheWidth: 100,
                          // height: 240,
                          // width: 2,

                          // errorBuilder: (context, error, stackTrace) {
                          //   // return Icon(
                          //   //   _getServiceIcon(item.notes),
                          //   //   color: Colors.teal.shade600,
                          //   //   size: 24,
                          //   // );
                          // },
                        ),
                        // child: Icon(
                        //   _getServiceIcon(item.notes),
                        //   color: Colors.teal.shade600,
                        //   size: 24,
                        // ),
                      ),
                      const SizedBox(width: 12),

                      // Service name and price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? 'Service',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                // Text(
                                //   item.brand ?? '',
                                //   style: TextStyle(
                                //     fontSize: 13,
                                //     color: Colors.grey.shade600,
                                //   ),
                                // ),
                                Text(
                                  item.model ?? 'no',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '₹${NumberFormat('#,##0').format(item.price ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // You can add original price with discount here if needed
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Quantity controls
                      Container(
                        padding: const EdgeInsets.only(
                          // left: 2,
                          right: 2,
                          top: 2,
                          bottom: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            // Decrease button
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () async {
                                if (item.qty.value > 1) {
                                  // Decrease quantity by 1
                                  cartCtrl.decreaseQty(item.cartId!);
                                } else {
                                  // Show remove dialog if quantity is 1
                                  print("don't tap me ");
                                  _showRemoveItemDialog(cartCtrl, item.cartId!);
                                }
                              },
                              splashRadius: 20,
                              padding: const EdgeInsets.all(4),
                            ),
                            // Quantity display
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Obx(() {
                                  // This ensures UI updates when quantity changes
                                  return Text(
                                    '${item.qty.value}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            // Increase button
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () async {
                                await cartCtrl.increaseQty(item.cartId!);
                              },
                              splashRadius: 20,
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Optional: Service details
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Text(
                      item.notes!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Item total and remove button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        final itemTotal = (item.price ?? 0) * item.qty.value;
                        return Text(
                          'Item total: ₹${NumberFormat('#,##0').format(itemTotal)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        );
                      }),
                      InkWell(
                        onTap: () => _showRemoveItemDialog(
                          cartCtrl,
                          cartCtrl.cartItems[index].cartId!,

                          // CartItem[index].cartId,
                          // cartItems[index].cartId,
                          // Make sure this is your Get.find() controller
                        ),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider for next item
                if (index < cartCtrl.cartItems.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    indent: 12,
                    endIndent: 12,
                  ),
              ],
            ),
          );
        },
        childCount: cartCtrl.cartItems.length,
        addSemanticIndexes: true,
      ),
    );
  }

  SliverToBoxAdapter _buildAddressTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 12, 0),
        child: Text(
          "Delivery Address".tr,
          style: _sectionTitleStyle.copyWith(color: Colors.grey.shade800),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAddressSection(CartController cartCtrl) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AddressWidget(),
      ),
    );
  }

  SliverToBoxAdapter _buildCheckoutSection(CartController cartCtrl) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
          color: Colors.white,
        ),
        child: CheckoutBar(cartCtrl: cartCtrl),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.teal.shade700),
                  backgroundColor: Colors.teal.shade100,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading your cart...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait a moment",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.teal.shade100, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Colors.teal.shade300,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Your cart is feeling light!",
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Add amazing services to get started with your purchase journey",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shadowColor: Colors.teal.withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore_sharp, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Browse Services",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Get.to(() => OrdersListScreen());
            },
            child: Text(
              "View Order History",
              style: TextStyle(
                color: Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOGS ====================
  void _showRemoveItemDialog(CartController cartCtrl, String cartId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade100, width: 2),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Remove Item?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to remove this item from your cart?",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        // ✅ FIXED: Use the passed cartId parameter
                        await cartCtrl.removeItem(cartId);

                        // Optional: Show snackbar after successful removal
                        Get.snackbar(
                          "Item Removed",
                          "Item has been removed from cart",
                          backgroundColor: Colors.white,
                          colorText: Colors.red,
                          borderRadius: 12,
                          duration: const Duration(seconds: 2),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Remove",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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
}
