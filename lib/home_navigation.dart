import 'package:flutter/material.dart';
import 'package:life_auctor/screens/home_screen.dart';
import 'package:life_auctor/screens/my_items_screen.dart';
import 'package:life_auctor/screens/notifications_screen.dart';
import 'package:life_auctor/screens/profile_screen.dart';
import 'package:life_auctor/screens/settings_screen.dart';
import 'package:life_auctor/screens/barcode_screen.dart';
import 'package:life_auctor/screens/add_item_screen.dart';
import 'package:life_auctor/screens/analytics_screen.dart';
import 'package:life_auctor/screens/history_screen.dart';
import 'package:life_auctor/screens/shopping_list/shopping_list_screen.dart';
import 'package:life_auctor/screens/community_screen.dart';
import 'package:life_auctor/widgets/nav_bar.dart/bottom_bar.dart';
import 'package:life_auctor/widgets/connectivity_banner.dart';
import 'package:life_auctor/utils/app_screen.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  AppScreen _currentScreen = AppScreen.home;

  final List<AppScreen> _navigationStack = [AppScreen.home];

  void _navigateToScreen(int index) {
    final screen = AppScreen.values.firstWhere((s) => s.value == index);
    setState(() {
      _navigationStack.add(screen);
      _currentScreen = screen;
    });
  }

  void _goBack() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        _currentScreen = _navigationStack.last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // build only the current screen
    Widget currentScreenWidget;
    switch (_currentScreen) {
      case AppScreen.notifications:
        currentScreenWidget = const NotificationsScreen();
        break;
      case AppScreen.home:
        currentScreenWidget = HomeScreen(onNavigate: _navigateToScreen);
        break;
      case AppScreen.profile:
        currentScreenWidget = ProfileScreen(onNavigate: _navigateToScreen);
        break;
      case AppScreen.settings:
        currentScreenWidget = SettingsScreen(onNavigate: _navigateToScreen);
        break;
      case AppScreen.myItems:
        currentScreenWidget = MyItemsScreen(
          onBack: _goBack,
          onNavigate: _navigateToScreen,
        );
        break;
      case AppScreen.barcode:
        currentScreenWidget = BarcodeScreen(
          onBack: _goBack,
          onNavigate: _navigateToScreen,
        );
        break;
      case AppScreen.addItem:
        currentScreenWidget = AddItemScreen(
          onBack: _goBack,
          onNavigate: _navigateToScreen,
        );
        break;
      case AppScreen.community:
        currentScreenWidget = CommunityScreen(
          onNavigate: _navigateToScreen,
          onBack: _goBack,
        );
        break;
      case AppScreen.analytics:
        currentScreenWidget = AnalyticsScreen(
          onNavigate: _navigateToScreen,
          onBack: _goBack,
        );
        break;
      case AppScreen.history:
        currentScreenWidget = HistoryScreen(
          onNavigate: _navigateToScreen,
          onBack: _goBack,
        );
        break;
      case AppScreen.shoppingList:
        currentScreenWidget = ShoppingListScreen(
          onNavigate: _navigateToScreen,
          onBack: _goBack,
        );
        break;
    }

    return Scaffold(
      body: WithConnectivityBanner(child: currentScreenWidget),
      bottomNavigationBar: _currentScreen.showsBottomBar
          ? BottomBar(
              currentIndex: _currentScreen.bottomBarIndex,
              onTap: (index) {
                final screen = AppScreen.values.firstWhere(
                  (s) => s.value == index,
                );
                setState(() {
                  _navigationStack.clear();
                  _navigationStack.add(screen);
                  _currentScreen = screen;
                });
              },
            )
          : null,
    );
  }
}
