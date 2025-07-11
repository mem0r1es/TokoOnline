import 'package:flutter_web/models/info_user.dart';
import 'package:flutter_web/models/product_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'pages/dashboard/dashboard.dart';
import 'pages/dashboard/isi.dart';
import 'pages/shop/our_product.dart';
import 'pages/shop/shops.dart';
import 'pages/shoppingcart/cart.dart';
import 'pages/shoppingcart/checkout_page.dart';
import 'pages/shoppingcart/shopping_cart.dart';
import 'pages/favorite/favorite_page.dart';
import 'pages/search/search_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/profile/add_address.dart';
import 'pages/history/history.dart';
import 'pages/about/about_page.dart';
import 'pages/contact/contact_page.dart';
import 'pages/auth/auth_dialog.dart';

final GoRouter goRouter = GoRouter(
  debugLogDiagnostics: true, 
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/isi',
      name: 'isi',
      builder: (context, state) => const Isi(),
    ),
    GoRoute(
      path: '/shop',
      name: 'shop',
      builder: (context, state) => const ShopsPage(),
    ),
    GoRoute(
      path: '/our-product',
      name: 'ourProduct',
      builder: (context, state) => OurProduct(),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartPages(),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/shopping-cart',
      name: 'shoppingCart',
      builder: (context, state) => const ShoppingCart(),
    ),
    GoRoute(
      path: '/favorit',
      name: 'favorite',
      builder: (context, state) => FavoritePage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/add-address',
      name: 'addAddress',
      builder: (context, state) => const AddAddress(),
    ),
    GoRoute(
      path: '/address',
      name: 'addressPage',
      builder: (context, state) {
        final address = state.extra is InfoUser ? state.extra as InfoUser : null;
        return AddAddress(existingAddress: address);
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => ProductInfoPage(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const ContactPage(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          final query = extra['query'] ?? '';
          final results = (extra['results'] ?? <Product>[]) as List<Product>;
          return SearchResultPage(query: query, results: results);
        }
        return const Scaffold(
          body: Center(child: Text('❌ Invalid search parameter')),
        );
      },
    ),
    GoRoute(
      path: '/auth',
      name: 'authDialog',
      builder: (context, state) => const AuthDialog(),
    ),

    GoRoute(
      path: '/404',
      name: 'notFound',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('❌ Halaman tidak ditemukan')),
      ),
    ),
  ],
);
