import 'package:flutter/material.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mentorship',
          style: TextStyle(
            color: Color(0xFF1A1F36),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1A1F36)),
            onPressed: () {
              // Navigate to search for mentors
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          // Mentorship Quests Section
          _buildSectionHeader('Mentorship Quests'),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuestCard(
                  'Career Path Quest',
                  'Create a career plan with your mentor.',
                  Icons.trending_up,
                  const Color(0xFF6772E5),
                ),
                _buildQuestCard(
                  'Skill Builder Quest',
                  'Learn a new skill from your mentor.',
                  Icons.build_circle,
                  const Color(0xFF24B47E),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            'View All Quests',
            () {
              // Navigate to view all quests
            },
          ),

          const SizedBox(height: 40),
          // Mentor Profiles Section
          _buildSectionHeader('Featured Mentors'),
          _buildMentorCard(
            'John Doe',
            'Software Engineer at Google',
            'Expert in Python and Machine Learning.',
            'https://randomuser.me/api/portraits/men/32.jpg',
          ),
          _buildMentorCard(
            'Jane Smith',
            'Data Scientist at Microsoft',
            'Specializes in AI and Big Data.',
            'https://randomuser.me/api/portraits/women/44.jpg',
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            'View All Mentors',
            () {
              // Navigate to view all mentors
            },
          ),

          const SizedBox(height: 40),
          // Live Sessions Section
          _buildSectionHeader('Upcoming Live Sessions'),
          _buildLiveSessionCard(
            'How to Crack Coding Interviews',
            'Hosted by John Doe',
            'Tomorrow at 6 PM',
            Colors.orange,
          ),
          _buildLiveSessionCard(
            'Introduction to AI',
            'Hosted by Jane Smith',
            'Next Friday at 7 PM',
            Colors.purple,
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            'View All Live Sessions',
            () {
              // Navigate to view all live sessions
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1F36),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildQuestCard(String title, String description, IconData icon, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 8,
        shadowColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF1A1F36).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentorCard(String name, String role, String expertise, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1A1F36).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expertise,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1A1F36).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveSessionCard(String title, String host, String time, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      host,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1A1F36).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F36).withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1A1F36).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6772E5), Color(0xFF24B47E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6772E5).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}