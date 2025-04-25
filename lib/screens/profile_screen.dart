import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  final TextEditingController _subjectController = TextEditingController();
  bool _isLoading = true;

  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: "cote",
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await firestore.collection('users').doc(_currentUser!.uid).get();
    setState(() {
      _userData = doc.data();
      _isLoading = false;
    });
  }

  Future<void> _addSubject() async {
    final newSubject = _subjectController.text.trim();
    if (newSubject.isEmpty) return;

    final updatedSubjects = [..._userData!['subjects'], newSubject];
    await firestore.collection('users').doc(_currentUser!.uid).update({
      'subjects': updatedSubjects,
    });
    _subjectController.clear();
    _loadUserProfile();
  }

  Future<void> _removeSubject(String subject) async {
    if (_userData!['role'] == 'teacher') return;

    final updatedSubjects = List<String>.from(_userData!['subjects']);
    updatedSubjects.remove(subject);

    await firestore.collection('users').doc(_currentUser!.uid).update({
      'subjects': updatedSubjects,
    });
    _loadUserProfile();
  }

  // Rating color coding method
  Color _getRatingColor(int rating) {
    if (rating < 1000) return Colors.red;
    if (rating < 1200) return Colors.orange;
    if (rating < 1400) return Colors.blue;
    if (rating < 1600) return Colors.green;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Basic Info
              Text(
                "Username: ${_userData!['username'] ?? 'Not set'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text("Email: ${_userData!['email']}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Role: ${_userData!['role']}", style: const TextStyle(fontSize: 16)),
              
              // Rating Section
              const SizedBox(height: 16),
              Text(
                "Quiz Rating: ${_userData!['quizRating'] ?? 1200}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getRatingColor(_userData!['quizRating'] ?? 1200),
                ),
              ),

              // Battle Statistics
              const SizedBox(height: 16),
              const Text(
                "Battle Statistics",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStatItem(
                "Battles Played", 
                _userData!['quizBattlesPlayed'] ?? 0
              ),
              _buildStatItem(
                "Battles Won", 
                _userData!['quizBattlesWon'] ?? 0
              ),
              _buildStatItem(
                "Battles Lost", 
                _userData!['quizBattlesLost'] ?? 0
              ),
              _buildStatItem(
                "Total Points Earned", 
                _userData!['totalPointsEarned'] ?? 0
              ),

              // Subjects Section
              const SizedBox(height: 16),
              const Text("Subjects:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: List<Widget>.from(
                  _userData!['subjects'].map<Widget>(
                    (subject) => Chip(
                      label: Text(subject),
                      deleteIcon: _userData!['role'] == 'student'
                          ? const Icon(Icons.close)
                          : null,
                      onDeleted: _userData!['role'] == 'student'
                          ? () => _removeSubject(subject)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Add Subject Section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(hintText: "Add new subject"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSubject,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build stat items
  Widget _buildStatItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value.toString(), 
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }
}