import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int _selectedIndex = 0;

  // Stats variables
  int _totalUsers = 0;
  int _todayOrders = 0;
  double _todayRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // Load all statistics from database
  Future<void> _loadStatistics() async {
    try {
      final users = await _databaseHelper.getTotalUsers();
      final todayOrders = await _databaseHelper.getTodayOrders();
      final todayRevenue = await _databaseHelper.getTodayRevenue();

      setState(() {
        _totalUsers = users;
        _todayOrders = todayOrders;
        _todayRevenue = todayRevenue;
      });

      print(
          "Statistics Loaded: Users: $_totalUsers, Orders: $_todayOrders, Revenue: RM$_todayRevenue");
    } catch (e) {
      print("Error loading statistics: $e");
    }
  }

  // Edit user dialog
  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);
    final usernameController = TextEditingController(text: user['username']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // Username cannot be changed
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = {
                  'id': user['id'],
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'username': user['username'],
                  'password': user['password'],
                };

                await _databaseHelper.updateUser(updatedUser);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete user confirmation
  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${user['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _databaseHelper.deleteUser(user['id']);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                _loadStatistics();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 150, // Set a fixed width for each card
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color), // Adjust icon size
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/adminLogin');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart),
                label: Text('Orders'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  // Overview Page
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dashboard Overview',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadStatistics,
                              tooltip: 'Refresh Statistics',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Flexible Stats Cards using Wrap
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildStatCard(
                              'Total Users',
                              _totalUsers.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              "Today's Orders",
                              _todayOrders.toString(),
                              Icons.today,
                              Colors.green,
                            ),
                            _buildStatCard(
                              "Today's Revenue",
                              'RM${_todayRevenue.toStringAsFixed(2)}',
                              Icons.attach_money,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Users Management Page
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _databaseHelper.fetchAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final users = snapshot.data ?? [];
                      if (users.isEmpty) {
                        return const Center(child: Text('No users found.'));
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(user['name'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${user['email'] ?? 'No email'}'),
                                  Text('Phone: ${user['phone'] ?? 'No phone'}'),
                                  Text(
                                      'Username: ${user['username'] ?? 'No username'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      _showEditUserDialog(context, user);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _showDeleteConfirmation(context, user);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Orders Management Page
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _databaseHelper.fetchAllOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final orders = snapshot.data ?? [];
                      if (orders.isEmpty) {
                        return const Center(child: Text('No orders found.'));
                      }

                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ExpansionTile(
                              title: Text('Order #${order['id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Placed by: ${order['user_name'] ?? 'Unknown'}'),
                                  Text(
                                      'Amount: RM${order['total_amount'].toStringAsFixed(2)}'),
                                  Text('Status: ${order['status']}'),
                                  Text('Date: ${order['created_at']}'),
                                ],
                              ),
                              children: [
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _databaseHelper
                                      .fetchOrderItems(order['id']),
                                  builder: (context, itemSnapshot) {
                                    if (itemSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (itemSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${itemSnapshot.error}'));
                                    }

                                    final items = itemSnapshot.data ?? [];
                                    if (items.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                            'No items found for this order.'),
                                      );
                                    }

                                    return Column(
                                      children: items.map((item) {
                                        return ListTile(
                                          title: Text(item['item_name']),
                                          subtitle: Text(
                                              'Quantity: ${item['quantity']}'),
                                          trailing: Text(
                                            'RM${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                                const Divider(),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    await _databaseHelper.updateOrderStatus(
                                        order['id'], value);
                                    setState(() {});
                                    _loadStatistics();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Order status updated to $value')),
                                    );
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'pending',
                                      child: Text('Mark as Pending'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'processing',
                                      child: Text('Mark as Processing'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'completed',
                                      child: Text('Mark as Completed'),
                                    ),
                                  ],
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Change Status'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}