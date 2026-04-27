import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DayDetailPage.dart';
class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}
class _HomepageState extends State<Homepage> {
  late final PageController _pageController;
  final int currentDay = DateTime.now().day;
  final int currentMonth = DateTime.now().month;
  late Stream<QuerySnapshot> _diaryStream;
  @override
  void initState() {
    super.initState();
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
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
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
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => debugPrint("Search button pressed"),
                          icon: Icon(
                            Icons.search_rounded,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => debugPrint("Menu button pressed"),
                          icon: Icon(
                            Icons.short_text_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedYear,
                              child: Text(
                              ),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                        _initializeDiaryStream();
                      });
                    },
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        );
                      },
                    ),
                  ),
                  Padding(
                      child: Row(
                        children: [
                          _buildTodayChip(),
                          const Spacer(),
                          _buildActionButton(
                            icon: Icons.mode_edit_outline,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

    final monthName = _getMonthName(month);
    final daysInMonth = _getDaysInMonth(month);
    final highlightedDays = _highlightedDays[month] ?? {};

    return AnimatedContainer(
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
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
                      ),
                    ),
                    Text(
                      'Total Entries: $totalEntries',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 7,
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
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                ? [
                                    BoxShadow(
                                          ? Colors.greenAccent
                                          : Colors.blueAccent,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                                  ? Colors.white
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                        ? Colors.grey.shade800.withOpacity(0.8)
                  ),
                  child: Text(
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
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


      children: [
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              style: TextStyle(
              ),
            ),
          ],
        ),
      ],
    );
  }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    );
  }


}
