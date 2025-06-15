import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DayDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}
class _HomepageState extends State<Homepage> {
  String selectedYear = '2025';
  late final PageController _pageController;
  final int currentDay = DateTime.now().day;
  final int currentMonth = DateTime.now().month;
  final Map<int, Set<int>> _highlightedDays = {}; // Month -> Set of days with entries
  late Stream<QuerySnapshot> _diaryStream;
  String? _userEmail; // For logged-in user's email
  late bool _isNightMode;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: currentMonth - 1,
      viewportFraction: 0.8,
    );
    _initializeUser();
    _updateTheme();
  }

  Future<void> _initializeUser() async {
    _userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userEmail == null) {
      Navigator.of(context).pop();
      return;
    }
    _initializeDiaryStream();
  }

  void _initializeDiaryStream() {
    _diaryStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_userEmail) // Use user's email as the document ID
        .collection('diary_entries')
        .where('date', isGreaterThanOrEqualTo: '$selectedYear-01-01')
        .where('date', isLessThanOrEqualTo: '$selectedYear-12-31')
        .snapshots();

    _diaryStream.listen((snapshot) {
      Map<int, Set<int>> newHighlightedDays = {};

      for (var doc in snapshot.docs) {
        final date = DateTime.parse(doc['date']);
        newHighlightedDays.putIfAbsent(date.month, () => {}).add(date.day);
      }

      setState(() {
        _highlightedDays.clear();
        _highlightedDays.addAll(newHighlightedDays);
      });
    });
  }

  void _updateTheme() {
    final hour = DateTime.now().hour;
    setState(() {
      _isNightMode = hour < 6 || hour >= 18;
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay on the page
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _isNightMode ? Colors.black : Colors.lightBlue,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => debugPrint("Search button pressed"),
                      icon: Icon(
                        Icons.search_rounded,
                        color: _isNightMode ? Colors.white : Colors.black,
                      ),
                      iconSize: 30,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => debugPrint("Menu button pressed"),
                      icon: Icon(
                        Icons.short_text_rounded,
                        color: _isNightMode ? Colors.white : Colors.black,
                      ),
                      iconSize: 35,
                    ),
                  ],
                ),
              ),
          DropdownButton<String>(
            value: selectedYear,
            dropdownColor: _isNightMode ? Colors.grey[850] : Colors.white,
            items: [
              DropdownMenuItem(
                value: '2025',
                child: Text(
                  '2025',
                  style: TextStyle(color: _isNightMode ? Colors.white : Colors.black),
                ),
              ),
              DropdownMenuItem(
                value: '2024',
                child: Text(
                  '2024',
                  style: TextStyle(color: _isNightMode ? Colors.white : Colors.black),
                ),
              ),
              DropdownMenuItem(
                value: '2023',
                child: Text(
                  '2023',
                  style: TextStyle(color: _isNightMode ? Colors.white : Colors.black),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedYear = value!;
                _initializeDiaryStream();
              });
            },
          ),

          const SizedBox(height: 15.0),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        _isNightMode
                            ? 'https://gifdb.com/images/high/night-sky-shooting-star-camp-fire-jfipafxw8m511uux.webp'
                            : 'https://i.gifer.com/Lx0q.gif',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: _buildMonthCard(screenWidth, index + 1),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _buildTodayChip(),
                    const Spacer(),
                    _buildActionButton(
                      icon: Icons.mode_edit_outline,
                      onPressed: () {
                        final currentDate =
                        DateTime(int.parse(selectedYear), currentMonth, currentDay);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DayDetailPage(date: currentDate),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10.0),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCard(double screenWidth, int month) {
    final monthName = _getMonthName(month);
    final daysInMonth = _getDaysInMonth(month);
    final highlightedDays = _highlightedDays[month] ?? {};
    int totalEntries = highlightedDays.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isNightMode ? Colors.black : Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8.0),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.network(
              _isNightMode
                  ? 'https://gifdb.com/images/high/night-sky-shooting-star-camp-fire-jfipafxw8m511uux.webp'
                  : 'https://i.gifer.com/Lx0q.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      monthName,
                      textScaleFactor: 2.5,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isNightMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      'Total Entries: $totalEntries',
                      style: TextStyle(
                        color: _isNightMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final day = index + 1;

                      return GestureDetector(
                        onTap: () {
                          final selectedDate =
                          DateTime(int.parse(selectedYear), month, day);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DayDetailPage(date: selectedDate),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: highlightedDays.contains(day)
                                ? (_isNightMode ? Colors.green : Colors.green)
                                : (_isNightMode ? Colors.black54 : Colors.white),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                            boxShadow: highlightedDays.contains(day)
                                ? [
                              BoxShadow(
                                color: _isNightMode
                                    ? Colors.greenAccent
                                    : Colors.blueAccent,
                                blurRadius: 6.0,
                              ),
                            ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: highlightedDays.contains(day)
                                  ? Colors.white
                                  : (_isNightMode ? Colors.white70 : Colors.black),
                              decoration: (day == currentDay && month == currentMonth)
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: _isNightMode
                        ? Colors.grey.shade800.withOpacity(0.8)
                        : Colors.blueGrey.shade50.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child:  Text(
                    _isNightMode?
                        '“After hard work, the quiet of night is a gift.”'
                        :'"Every day is a fresh start"',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                      color: _isNightMode? Colors.white70:Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayChip() {
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    String formattedDate = DateFormat('MMM d, yyyy').format(now);

    IconData timeIcon;
    Color iconColor;

    if (now.hour >= 6 && now.hour < 18) {
      timeIcon = Icons.wb_sunny_rounded;
      iconColor = Colors.orange;
    } else {
      timeIcon = Icons.nights_stay_rounded;
      iconColor = Colors.indigo;
    }

    return Container(
      width: 154.0,
      height: 50.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(25.0),
        color: _isNightMode ? Colors.black : Colors.white,
      ),
      child: Row(
        children: [
          Icon(timeIcon, color: iconColor),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                    color: _isNightMode ? Colors.white70 : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formattedDate
                  ,
                  style: TextStyle(
                    color: _isNightMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: _isNightMode ? Colors.black : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _isNightMode ? Colors.white : Colors.black),
      ),
    );
  }

  String _getMonthName(int month) => DateFormat('MMM').format(DateTime(2025, month));

  int _getDaysInMonth(int month) => DateTime(2025, month + 1, 0).day;
}
