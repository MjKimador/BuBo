// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bubo/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeWrapper(),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeScreen(),
    Text("add customer"),
    Text("see loan offsers"),
    Text("chatbot")
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 30, 215, 96),
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 57, 58, 58),
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(5.0, 5.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: GNav(
            backgroundColor: const Color.fromARGB(255, 57, 58, 58),
            rippleColor: Colors.white,
            hoverColor: Colors.white,
            haptic: true,
            tabBorderRadius: 15,
            curve: Curves.easeOutExpo,
            duration: Duration(milliseconds: 300),
            gap: 8,
            color: Colors.white70,
            activeColor: Colors.white,
            iconSize: 24,
            tabBackgroundColor: Colors.white.withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            onTabChange: onTabTapped,
            tabs: [
              GButton(
                icon: Icons.home_filled,
                text: "Home",
              ),
              GButton(
                icon: Icons.add_circle,
                text: "Add customer",
              ),
              GButton(
                icon: Icons.monetization_on,
                text: 'Loan Offers',
              ),
              GButton(
                icon: Icons.chat_bubble,
                text: "Chatbot",
              )
            ],
          ),
        ),
      ),
    );
  }
}
