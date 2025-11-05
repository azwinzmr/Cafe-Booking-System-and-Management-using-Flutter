import 'package:flutter/material.dart';
import 'rating_page.dart';

class ReceiptPage extends StatelessWidget {
  final List<Map<String, dynamic>> shoppingBag;
  final double totalAmount;
  final double discount;
  final bool isTakeaway;

  const ReceiptPage({
    super.key,
    required this.shoppingBag,
    required this.totalAmount,
    required this.discount,
    required this.isTakeaway,
  });

  double getFinalAmount(double totalAmount) {
    double serviceTax = 0.06;
    double takeawayFee = 0.20;
    double taxAmount = totalAmount * serviceTax;
    double takeawayCharge = isTakeaway ? takeawayFee : 0.0;
    return totalAmount + taxAmount + takeawayCharge - discount;
  }

  @override
  Widget build(BuildContext context) {
    double finalAmount = getFinalAmount(totalAmount);
    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text("Receipt")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Restaurant Booking',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Date: ${now.day}/${now.month}/${now.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shoppingBag.length,
                      itemBuilder: (context, index) {
                        var item = shoppingBag[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['name']} x${item['quantity']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Text(
                                'RM${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('RM${totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Tax (6%):'),
                        Text('RM${(totalAmount * 0.06).toStringAsFixed(2)}'),
                      ],
                    ),
                    if (isTakeaway)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Takeaway Fee:'),
                          Text('RM0.20'),
                        ],
                      ),
                    if (discount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:'),
                          Text('-RM${discount.toStringAsFixed(2)}'),
                        ],
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RM${finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingPage(shoppingBag: shoppingBag),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Rate Your Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}