import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/screens/main_screen/tabs/account_tab.dart';
import 'package:cab_driver/ui/screens/main_screen/tabs/earning_tab.dart';
import 'package:cab_driver/ui/screens/main_screen/tabs/home_tab.dart';
import 'package:cab_driver/ui/screens/main_screen/tabs/rating_tab.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedTab = 0;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [HomeTab(), EarningTab(), RatingTab(), AccountTab()]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "Earning"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Rating"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        currentIndex: selectedTab,
        selectedItemColor: MyColors.colorOrange,
        unselectedItemColor: MyColors.colorIcon,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: changeSelectedTab,
      ),
    );
  }

  changeSelectedTab(int index) {
    setState(() {
      selectedTab = index;
      tabController.index = index;
    });
  }
}
