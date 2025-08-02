import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import "./screens/activity/activity_screen.dart";
import "screens/point-of-sales/point_of_sales_screen.dart";
import "screens/reports/reports_screen.dart";
import "screens/settings/settings_screen.dart";
import 'widgets/drawer_list_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rato POS',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PointOfSaleScreen(),
    const ActivityScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurant POS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red[900],
          ),
        ),
        centerTitle: true,
        actions: [const DateTimeBadge(), const SizedBox(width: 30)],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Custom Header
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red,
                    Colors.red.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/rato_khata.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // App Title
                      Text(
                        'Rato-POS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // Subtitle
                      Text(
                        'Restaurant Management System',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Menu Items Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      DrawerListItem(
                        title: 'Point Of Sale',
                        icon: Icons.point_of_sale,
                        isSelected: _currentIndex == 0,
                        onTap: () {
                          _onItemTapped(0);
                          Navigator.pop(context);
                        },
                      ),
                      DrawerListItem(
                        title: 'Activity',
                        icon: Icons.history,
                        isSelected: _currentIndex == 1,
                        onTap: () {
                          _onItemTapped(1);
                          Navigator.pop(context);
                        },
                      ),
                      DrawerListItem(
                        title: 'Reports',
                        icon: Icons.bar_chart,
                        isSelected: _currentIndex == 2,
                        onTap: () {
                          _onItemTapped(2);
                          Navigator.pop(context);
                        },
                      ),
                      DrawerListItem(
                        title: 'Settings',
                        icon: Icons.settings,
                        isSelected: _currentIndex == 3,
                        onTap: () {
                          _onItemTapped(3);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}

class DateTimeBadge extends StatefulWidget {
  const DateTimeBadge({Key? key}) : super(key: key);

  @override
  _DateTimeBadgeState createState() => _DateTimeBadgeState();
}

class _DateTimeBadgeState extends State<DateTimeBadge> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      // Nepal timezone is UTC+5:45
      _currentTime = DateTime.now().toUtc().add(
        const Duration(hours: 5, minutes: 45),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey[400]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateFormat.format(_currentTime),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              timeFormat.format(_currentTime),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
