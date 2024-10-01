import 'package:flutter/material.dart';

class SocialFeaturesScreen extends StatelessWidget {
  const SocialFeaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Features'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Friend Requests
            _buildSectionTitle('Friend Requests'),
            _buildFriendRequestCard('John Doe', '2 mutual friends', context),
            _buildFriendRequestCard('Jane Smith', '5 mutual friends', context),

            const SizedBox(height: 20),

            // Section 2: Achievements
            _buildSectionTitle('Your Achievements'),
            _buildAchievementCard(
              'Master of Flutter',
              'Completed 50 Flutter projects',
              'March 2024',
              context,
            ),
            _buildAchievementCard(
              'AI Expert',
              'Completed AI Certification',
              'August 2024',
              context,
            ),

            const SizedBox(height: 20),

            // Section 3: Activity Feed
            _buildSectionTitle('Recent Activity'),
            _buildActivityCard(
              'Emma liked your post',
              '2 hours ago',
              Icons.thumb_up,
            ),
            _buildActivityCard(
              'David commented on your photo',
              '4 hours ago',
              Icons.comment,
            ),
            _buildActivityCard(
              'You earned a new badge: "Top Learner"',
              'Yesterday',
              Icons.emoji_events,
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  // Widget to build Friend Request cards
  Widget _buildFriendRequestCard(String name, String mutualFriends, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
        ),
        title: Text(name),
        subtitle: Text(mutualFriends),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                // Accept friend request logic
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                // Decline friend request logic
              },
            ),
          ],
        ),
      ),
    );
  }
  //Nothing

  // Widget to build Achievement cards
  Widget _buildAchievementCard(String title, String description, String date, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const Icon(Icons.star, size: 40, color: Colors.amber),
        title: Text(title),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date),
            const Icon(Icons.share, color: Colors.teal),

          ],
        ),
      ),
    );
  }

  // Widget to build Activity Feed cards
  Widget _buildActivityCard(String activity, String time, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.teal),
        title: Text(activity),
        subtitle: Text(time),
      ),
    );
  }
}
