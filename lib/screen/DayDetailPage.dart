import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayDetailPage extends StatefulWidget {
  final DateTime date;

  const DayDetailPage({super.key, required this.date});

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  String _lastSavedContent = '';

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  /// Get the current logged-in user
  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      // Handle user not logged in (e.g., redirect to login screen)
      Navigator.of(context).pop();
    } else {
      _fetchNote();
    }
  }

  /// Fetch the saved note for the selected date from Firestore
  Future<void> _fetchNote() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.email) // Use email as the document ID
          .collection('diary_entries')
          .doc(formattedDate)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          _controller.text = snapshot.get('content');
          _lastSavedContent = snapshot.get('content');
        });
      }
    } catch (e) {
      debugPrint("Error fetching note: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Save or update the note in Firestore
  Future<void> _saveNote() async {
    if (_currentUser == null) return;

    String content = _controller.text;
    if (content == _lastSavedContent) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.email) // Use email as the document ID
          .collection('diary_entries')
          .doc(formattedDate)
          .set({
        'date': formattedDate,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _lastSavedContent = content;
      });

      _showSuccessMessage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e')),
      );
    }
  }

  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: Text(
        'Note saved successfully!',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d, yyyy').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How was your day?',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts here...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Note',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
