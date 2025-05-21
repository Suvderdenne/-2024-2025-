import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/family_member.dart';
import 'edit_clan_member_screen.dart';
import '../api/api_service.dart';

class ClanMemberDetailScreen extends StatelessWidget {
  final FamilyMember member;
  final AuthService authService;
  final VoidCallback onMemberUpdated;

  const ClanMemberDetailScreen({
    super.key,
    required this.member,
    required this.authService,
    required this.onMemberUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with background image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green[800]!, Colors.green[600]!],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          member.gender == 'Эр' ? Icons.male : Icons.female,
                          size: 40,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${member.lastname ?? ''} ${member.name}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        member.relationshipType,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditClanMemberScreen(
                            authService: authService,
                            member: member,
                            onMemberUpdated: onMemberUpdated,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildSection(context, 'Хувийн мэдээлэл', Icons.person, [
                    _buildInfoCard(
                      'Хүйс',
                      member.gender,
                      Icons.person,
                      Colors.blue,
                    ),
                    _buildInfoCard(
                      'Төрсөн огноо',
                      DateFormat('yyyy-MM-dd').format(member.birthdate),
                      Icons.cake,
                      Colors.orange,
                    ),
                    if (member.diedate != null)
                      _buildInfoCard(
                        'Нас барсан огноо',
                        DateFormat('yyyy-MM-dd').format(member.diedate!),
                        Icons.person_off,
                        Colors.red,
                      ),
                  ]),

                  const SizedBox(height: 24),

                  // Additional Information Section
                  _buildSection(context, 'Нэмэлт мэдээлэл', Icons.info, [
                    if (member.birthplace != null)
                      _buildInfoCard(
                        'Төрсөн газар',
                        '${member.birthplace!['name']} (${member.birthplace!['country']})',
                        Icons.location_on,
                        Colors.green,
                      ),
                    if (member.generation != null)
                      _buildInfoCard(
                        'Үе',
                        '${member.generation!['uyname']} (${member.generation!['level']})',
                        Icons.generating_tokens,
                        Colors.purple,
                      ),
                    if (member.urgiinovog != null)
                      _buildInfoCard(
                        'Ургийн овог',
                        member.urgiinovog!['urgiinovog'],
                        Icons.family_restroom,
                        Colors.brown,
                      ),
                  ]),

                  if (member.biography != null &&
                      member.biography!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(context, 'Намтар', Icons.book, [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          member.biography!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[800], size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
