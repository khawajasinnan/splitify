import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/supabase_config.dart';
import 'home_screen.dart';
import 'groups_screen.dart';
import 'expenses_screen.dart';
import 'balances_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

/// Main dashboard with bottom navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GroupsScreen(),
    const ExpensesScreen(),
    const BalancesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : const Color(0xFFF5F7FA),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? AppColors.shadowDark 
                  : Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          selectedItemColor: AppColors.magmaOrange,
          unselectedItemColor: isDark 
              ? AppColors.textSecondary 
              : const Color(0xFF718096),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_rounded),
              label: 'Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Balances',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
