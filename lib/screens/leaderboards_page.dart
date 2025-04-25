import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: "cote",
  );

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .orderBy('quizRating', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Filter and prepare student users
          final studentUsers = snapshot.data!.docs.where((doc) {
            final userData = doc.data() as Map<String, dynamic>;
            return userData['role'] == 'student';
          }).toList();

          return ListView.builder(
            itemCount: studentUsers.length,
            itemBuilder: (context, index) {
              var userData = studentUsers[index].data() as Map<String, dynamic>;
              
              return _buildLeaderboardItem(
                rank: index + 1,
                username: userData['username'] ?? 'Unknown User',
                rating: userData['quizRating'] ?? 1200,
                battlesWon: userData['quizBattlesWon'] ?? 0,
                totalBattles: userData['quizBattlesPlayed'] ?? 0,
                isCurrentUser: userData['username'] == _currentUser?.displayName,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String username,
    required int rating,
    required int battlesWon,
    required int totalBattles,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.deepPurple.withOpacity(0.3) : Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.deepPurple : Colors.white24, 
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                username,
                style: TextStyle(
                  color: isCurrentUser ? Colors.deepPurple : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Rating: $rating',
              style: TextStyle(
                color: _getRatingColor(rating),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Battles: $battlesWon/$totalBattles',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  // Rank color based on position
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold color
      case 2:
        return const Color(0xFFC0C0C0); // Silver color
      case 3:
        return const Color(0xFFCD7F32); // Bronze color
      default:
        return Colors.grey;
    }
  }

  // Rating color coding
  Color _getRatingColor(int rating) {
    if (rating < 1000) return Colors.red;
    if (rating < 1200) return Colors.orange;
    if (rating < 1400) return Colors.blue;
    if (rating < 1600) return Colors.green;
    return Colors.purple;
  }
}