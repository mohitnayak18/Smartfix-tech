// lib/screens/repairs_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smartfixapp/api_calls/services/aapi_service.dart';


class RepairsScreen extends StatefulWidget {
  final MobileModel model;
  const RepairsScreen({super.key, required this.model});

  @override
  State<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends State<RepairsScreen> {
  late Future<List<RepairProduct>> _repairsFuture;

  @override
  void initState() {
    super.initState();
    _repairsFuture = ApiService.fetchRepairsForModel(widget.model.id /*, token: '...'*/);
  }

  Future<void> _refresh() async {
    setState(() {
      _repairsFuture = ApiService.fetchRepairsForModel(widget.model.id);
    });
    await _repairsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.model.brand} ${widget.model.name}'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<RepairProduct>>(
          future: _repairsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _refresh, child: const Text('Retry'))
                ]),
              );
            } else {
              final list = snapshot.data!;
              if (list.isEmpty) {
                return const Center(child: Text('No repair services found for this model.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final item = list[idx];
                  return _RepairCard(item: item, onTap: () {
                    // open product detail or add-to-cart flow
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _RepairDetailBottomSheet(product: item, model: widget.model),
                    );
                  });
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  final RepairProduct item;
  final VoidCallback onTap;
  const _RepairCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: item.imageUrl != null
                  ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.contain)
                  : const Icon(Icons.build, size: 42),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(item.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class _RepairDetailBottomSheet extends StatelessWidget {
  final RepairProduct product;
  final MobileModel model;
  const _RepairDetailBottomSheet({required this.product, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // for keyboard
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${model.brand} ${model.name}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(child: Text(product.description)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(product.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // add-to-cart or proceed flow
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart (demo)')));
                  },
                  child: const Text('Book / Add'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
