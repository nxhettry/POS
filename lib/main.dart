import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import "./screens/activity/activity_screen.dart";
import "screens/point-of-sales/point_of_sales_screen.dart";
import "screens/reports/reports_screen.dart";
import "screens/settings/settings_screen.dart";

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
      theme: ThemeData(primarySwatch: Colors.blue),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red[300]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/images/rato_khata.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    'Rato-POS',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.point_of_sale,
                color: _currentIndex == 0 ? Colors.grey[800] : Colors.grey[600],
                size: 28,
              ),
              title: Text(
                'Point Of Sale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _currentIndex == 0
                      ? Colors.grey[900]
                      : Colors.grey[700],
                ),
              ),
              selected: _currentIndex == 0,
              selectedTileColor: Colors.grey[300],
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.history,
                color: _currentIndex == 1 ? Colors.grey[800] : Colors.grey[600],
                size: 28,
              ),
              title: Text(
                'Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _currentIndex == 1
                      ? Colors.grey[900]
                      : Colors.grey[700],
                ),
              ),
              selected: _currentIndex == 1,
              selectedTileColor: Colors.grey[300],
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.bar_chart,
                color: _currentIndex == 2 ? Colors.grey[800] : Colors.grey[600],
                size: 28,
              ),
              title: Text(
                'Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _currentIndex == 2
                      ? Colors.grey[900]
                      : Colors.grey[700],
                ),
              ),
              selected: _currentIndex == 2,
              selectedTileColor: Colors.grey[300],
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: _currentIndex == 3 ? Colors.grey[800] : Colors.grey[600],
                size: 28,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _currentIndex == 3
                      ? Colors.grey[900]
                      : Colors.grey[700],
                ),
              ),
              selected: _currentIndex == 3,
              selectedTileColor: Colors.grey[300],
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
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
