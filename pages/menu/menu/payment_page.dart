import 'package:flutter/material.dart';
import '../receipt/receipt_page.dart';
import '../../database/database_helper.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> shoppingBag;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.shoppingBag,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController discountController = TextEditingController();
  bool isTakeaway = false;
  double discount = 0.0;
  double serviceTax = 0.06; // 6% service tax
  double takeawayFee = 0.20; // RM0.20 takeaway fee

  String? selectedPaymentMethod;
  final List<String> paymentMethods = ['Cash', 'Credit Card', 'Online Banking'];

  double getFinalAmount() {
    //service tax logic
    double taxAmount = widget.totalAmount * serviceTax;
    //takeaway fee logic
    double takeawayCharge = isTakeaway ? takeawayFee : 0.0;
    // final ampunt calculation logic
    return widget.totalAmount + taxAmount + takeawayCharge - discount;
  }

  void showConfirmationDialog() async {
    final finalAmount = getFinalAmount();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Payment"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Subtotal: RM${widget.totalAmount.toStringAsFixed(2)}'),
                Text('Service Tax (6%): RM${(widget.totalAmount * serviceTax).toStringAsFixed(2)}'),
                if (isTakeaway) const Text('Takeaway Fee: RM0.20'),
                if (discount > 0) Text('Discount: -RM${discount.toStringAsFixed(2)}'),
                const Divider(),
                Text(
                  'Total Amount: RM${finalAmount.toStringAsFixed(2)}', //Displays the final amount formatted to two decimal places
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Payment Method: ${selectedPaymentMethod ?? "Not selected"}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: selectedPaymentMethod == null
                  ? null
                  : () async {
                      // Step 1: Insert order into the database
                      final dbHelper = DatabaseHelper();
                      final orderId = await dbHelper.insertOrder({
                        'user_id': 1, // Replace with actual user ID if available
                        'total_amount': finalAmount,
                        'status': 'completed', // Or 'pending' based on workflow
                      });

                      // Step 2: Insert order items into the database
                      for (var item in widget.shoppingBag) {
                        await dbHelper.insertOrderItem({
                          'order_id': orderId,
                          'item_name': item['name'],
                          'quantity': item['quantity'],
                          'price': item['price'],
                        });
                      }

                      // Step 3: Navigate to receipt page and show success message
                      Navigator.pop(context); // Close the confirmation dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment Successful!")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceiptPage(
                            shoppingBag: widget.shoppingBag,
                            totalAmount: widget.totalAmount,
                            discount: discount,
                            isTakeaway: isTakeaway,
                          ),
                        ),
                      );
                    },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double finalAmount = getFinalAmount();

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.shoppingBag.length,
                itemBuilder: (context, index) {
                  var item = widget.shoppingBag[index];
                  return ListTile(
                    leading: Image.asset(
                      item['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name']),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: Text(
                      'RM${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: paymentMethods.map((method) {
                  return RadioListTile<String>(
                    title: Text(method),
                    value: method,
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Additional Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Takeaway'),
                      subtitle: const Text('Additional RM0.20 fee'),
                      value: isTakeaway,
                      onChanged: (bool value) {
                        setState(() {
                          isTakeaway = value;
                        });
                      },
                    ),
                    const Divider(),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Code',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        // Simple discount code implementation
                        if (value.toUpperCase() == 'SAVE10') {
                          setState(() {
                            //10% discount calculation
                            discount = widget.totalAmount * 0.10; // 10% discount
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('10% Discount Applied!')),
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid Discount Code')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtotal: RM${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Service Tax (6%): RM${(widget.totalAmount * serviceTax).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (isTakeaway)
                      const Text(
                        'Takeaway Fee: RM0.20',
                        style: TextStyle(fontSize: 16),
                      ),
                    if (discount > 0)
                      Text(
                        'Discount: -RM${discount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    const Divider(),
                    Text(
                      'Total Amount: RM${finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedPaymentMethod == null ? null : showConfirmationDialog,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Proceed to Payment'),
        ),
      ),
    );
  }
}
