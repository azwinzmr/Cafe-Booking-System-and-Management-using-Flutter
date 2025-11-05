import 'package:flutter/material.dart';
import 'pages/admin/admin_dash.dart';
import 'pages/admin/admin_login_page.dart';
import 'pages/user/user_login_page.dart';
import 'pages/user/registration.dart';
import 'pages/navigation_home.dart';
import 'pages/menu/menu_page.dart';
import 'pages/menu/shopping_bag.dart';
import 'pages/menu/payment_page.dart';
import 'pages/receipt/receipt_page.dart';
import 'pages/receipt/rating_page.dart';
import 'pages/splash_page.dart';
import 'pages/welcome_page.dart';
import 'pages/menu/menu_view_page.dart';


void main() {
  runApp(const RestaurantBookingApp());
}

class RestaurantBookingApp extends StatelessWidget {
  const RestaurantBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6857a5),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/menu': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return MenuPage(isGuest: args?['isGuest'] ?? false);
        },
        '/': (context) => const SplashPage(),
        '/welcome': (context) => const WelcomePage(),
        '/adminLogin': (context) => AdminLoginPage(),
        '/userLogin': (context) => UserLoginPage(),
        '/registration': (context) => const RegistrationPage(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/userDashboard': (context) => const NavigationHome(),
        //'/menu': (context) => const MenuPage(isGuest: null,),
        '/menuview': (context) => const MenuViewPage(isGuest: null,),
        '/shoppingBag': (context) => ShoppingBagPage(
          shoppingBag: [],
          onItemRemoved: (index) {},
          onOrderCompleted: (order) {},
        ),
        '/payment': (context) => PaymentPage(
          totalAmount: 0.0,
          shoppingBag: [],
        ),
        '/receipt': (context) => ReceiptPage(
          shoppingBag: [],
          totalAmount: 0.0,
          discount: 0.0,
          isTakeaway: false,
        ),
        '/rating': (context) => RatingPage(shoppingBag: []),
      },
    );
  }
}