import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  final List<Map<String, dynamic>> shoppingBag;

  const RatingPage({super.key, required this.shoppingBag});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  Map<int, double> ratings = {};
  Map<int, TextEditingController> reviewControllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.shoppingBag.length; i++) {
      ratings[i] = 0.0;
      reviewControllers[i] = TextEditingController();
    }
  }

  void _submitRatings() {
    List<Map<String, dynamic>> reviewData = [];

    for (int i = 0; i < widget.shoppingBag.length; i++) {
      reviewData.add({
        'item_name': widget.shoppingBag[i]['name'],
        'rating': ratings[i] ?? 0.0,
        'review': reviewControllers[i]?.text ?? '',  // Fixed the syntax error here
      });
    }

    // Show summary dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thank You for Your Feedback!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: reviewData.map((review) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['item_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Rating: ${review['rating']?.toStringAsFixed(1)}⭐'),
                    if (review['review'].isNotEmpty)
                      Text('Review: ${review['review']}'),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Items')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.shoppingBag.length,
              itemBuilder: (context, index) {
                var item = widget.shoppingBag[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item['image']!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Rate this item:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: ratings[index] ?? 0,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: '${ratings[index]?.toStringAsFixed(1)}',
                          onChanged: (value) {
                            setState(() {
                              ratings[index] = value;
                            });
                          },
                        ),
                        Text(
                          'Rating: ${ratings[index]?.toStringAsFixed(1)} stars',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: reviewControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Write your review',
                            border: OutlineInputBorder(),
                            hintText: 'Tell us what you think about this item...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submitRatings,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Submit Ratings'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    for (var controller in reviewControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}