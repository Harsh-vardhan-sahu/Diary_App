import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Auth_screen/login.dart';
import 'DayDetailPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String selectedYear = '2026';
  late final PageController _pageController;
  final int currentDay = DateTime.now().day;
  final int currentMonth = DateTime.now().month;

  final Map<int, Set<int>> _highlightedDays = {};

  late Stream<QuerySnapshot> _diaryStream;
  String? _userEmail;

  String _currentMode = 'night'; // morning, noon, lateNoon, evening, night

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
        .doc(_userEmail)
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
    final now = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30)); // IST
    final hour = now.hour;
    final minute = now.minute;

    String newMode = 'night';

    if (hour < 12) {
      newMode = 'morning';
    } else if (hour < 16) {
      newMode = 'noon';
    } else if (hour < 17 || (hour == 17 && minute < 30)) {
      newMode = 'lateNoon';
    } else if (hour < 19) {
      newMode = 'evening';
    }

    if (newMode != _currentMode) {
      setState(() => _currentMode = newMode);
    }
  }

// ==================== Mode-based Getters ====================
  Color get backgroundColor => switch (_currentMode) {
        'morning' => Colors.lightBlue,
        'noon' => Colors.orange.shade300,
        'lateNoon' => Colors.deepOrange.shade400,
        'evening' => Colors.indigo.shade700,
        _ => Colors.black,
      };

  Color get cardColor => switch (_currentMode) {
        'morning' => Colors.lightBlueAccent,
        'noon' => Colors.amber.shade400,
        'lateNoon' => Colors.orange.shade600,
        'evening' => Colors.deepPurple.shade600,
        _ => Colors.black,
      };

  Color get textColor => _currentMode == 'night' ? Colors.white : Colors.black;

  Color get subtleTextColor => switch (_currentMode) {
        'night' || 'evening' => Colors.white70,
        _ => Colors.black54,
      };

  String get backgroundImageUrl => switch (_currentMode) {
        'morning' =>
          'https://drive.google.com/uc?export=view&id=1pKaLJwddpM3P8FoKhU2hjOgKLUMfQdzI',
        'noon' =>
          'https://drive.google.com/uc?export=view&id=1jg0dE03mmRur4ynS17gmSgCj8CjZftou',
        'lateNoon' =>
          'https://drive.google.com/uc?export=view&id=1aBFd5LGZ3is1WP5h1HhoveeP73LllQPI',
        'evening' =>
          'https://drive.google.com/uc?export=view&id=1ahDS_lgU0ohCtU9_6-WGcaEuPvWhr0Al',
        _ =>
          'https://gifdb.com/images/high/night-sky-shooting-star-camp-fire-jfipafxw8m511uux.webp', // night is already good
      };

  String get quote => switch (_currentMode) {
        'morning' => '"Every day is a fresh start"',
        'noon' => '"The sun is high, and so is your potential"',
        'lateNoon' => '"Golden hours bring golden thoughts"',
        'evening' => '"As the day ends, reflections begin"',
        _ => '“After hard work, the quiet of night is a gift.”',
      };

// ==================== Safe Image Widget ====================
  Widget _buildBackgroundImage() {
    return Image.network(
      backgroundImageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: cardColor.withOpacity(0.9),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_rounded,
                    size: 60, color: Colors.white70),
                SizedBox(height: 8),
                Text(
                  'Background unavailable',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
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
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true, // Helps background extend fully
        backgroundColor:
            Colors.transparent, // Important: let background image show
        body: SafeArea(
          child: Stack(
// Use Stack so background is behind everything
            children: [
// Full-screen Background Image
              Positioned.fill(
                child: Image.network(
                  backgroundImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: backgroundColor);
                  },
                ),
              ),

// Main Content Column
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
// Top Transparent Bar (Search + Menu)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => debugPrint("Search button pressed"),
                          icon: Icon(
                            Icons.search_rounded,
                            color: textColor.withOpacity(0.95),
                            size: 30,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => debugPrint("Menu button pressed"),
                          icon: Icon(
                            Icons.short_text_rounded,
                            color: textColor.withOpacity(0.95),
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),

// Year Dropdown (kept slightly visible)
                  DropdownButton<String>(
                    value: selectedYear,
                    dropdownColor: _currentMode == 'night'
                        ? Colors.grey[850]!.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    items: ['2025', '2026', '2027']
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(
                                year,
                                style: TextStyle(color: textColor),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                        _initializeDiaryStream();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

// Calendar Area (remains as before)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: _buildMonthCard(index + 1),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

// Bottom Area - Transparent Glass Effect
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _currentMode == 'night'
                            ? Colors.black.withOpacity(0.45)
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildTodayChip(),
                          const Spacer(),
                          _buildActionButton(
                            icon: Icons.mode_edit_outline,
                            onPressed: () {
                              final currentDate = DateTime(
                                int.parse(selectedYear),
                                currentMonth,
                                currentDay,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DayDetailPage(date: currentDate),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCard(int month) {
    final monthName = _getMonthName(month);
    final daysInMonth = _getDaysInMonth(month);
    final highlightedDays = _highlightedDays[month] ?? {};
    final totalEntries = highlightedDays.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8.0)],
      ),
      child: Stack(
        children: [
// Background Image with error handling
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: _buildBackgroundImage(),
          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
// Month Title + Entries Count
                Column(
                  children: [
                    Text(
                      monthName,
                      textScaleFactor: 2.5,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Total Entries: $totalEntries',
                      style: TextStyle(
                        color: subtleTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

// Calendar Grid
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isHighlighted = highlightedDays.contains(day);
                      final isToday =
                          (day == currentDay && month == currentMonth);

                      return GestureDetector(
                        onTap: () {
                          final selectedDate =
                              DateTime(int.parse(selectedYear), month, day);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DayDetailPage(date: selectedDate),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHighlighted
                                ? Colors.green
                                : (_currentMode == 'night'
                                    ? Colors.black54
                                    : Colors.white),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1.5),
                            boxShadow: isHighlighted
                                ? [
                                    BoxShadow(
                                      color: _currentMode == 'night'
                                          ? Colors.greenAccent
                                          : Colors.blueAccent,
                                      blurRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isHighlighted
                                  ? Colors.white
                                  : (_currentMode == 'night'
                                      ? Colors.white70
                                      : Colors.black),
                              decoration:
                                  isToday ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

// Inspirational Quote
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _currentMode == 'night'
                        ? Colors.grey.shade800.withOpacity(0.8)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    quote,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: subtleTextColor,
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
    final now =
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final formattedDate = DateFormat('MMM d, yyyy').format(now);

    final isNightOrEvening =
        _currentMode == 'night' || _currentMode == 'evening';
    final timeIcon =
        isNightOrEvening ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded;
    final iconColor =
        isNightOrEvening ? Colors.indigoAccent : Colors.orangeAccent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(timeIcon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: TextStyle(
                color: subtleTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              formattedDate,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color:
              Colors.white.withOpacity(_currentMode == 'night' ? 0.15 : 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: textColor, size: 26),
      ),
    );
  }

  String _getMonthName(int month) =>
      DateFormat('MMM').format(DateTime(2026, month));

  int _getDaysInMonth(int month) => DateTime(2026, month + 1, 0).day;
}
