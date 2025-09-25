import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/rating_service.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Achievements'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          return Consumer<RatingService>(
            builder: (context, ratingService, _) {
              final userReviews = ratingService.reviews
                  .where((review) => review.userId == authService.currentUserId)
                  .toList();
              
              final totalReviews = userReviews.length;
              final points = totalReviews * 5; // 5 points per review
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User stats card
                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: FaIcon(
                                FontAwesomeIcons.user,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${authService.currentUserName ?? 'Wing Lover'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Wing & Beer Enthusiast',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  context,
                                  icon: FontAwesomeIcons.star,
                                  label: 'Reviews',
                                  value: totalReviews.toString(),
                                ),
                                _buildStatItem(
                                  context,
                                  icon: FontAwesomeIcons.coins,
                                  label: 'Points',
                                  value: points.toString(),
                                ),
                                _buildStatItem(
                                  context,
                                  icon: FontAwesomeIcons.trophy,
                                  label: 'Level',
                                  value: _getLevel(totalReviews).toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Achievements section
                    Text(
                      'Achievements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildAchievementCard(
                      context,
                      icon: FontAwesomeIcons.baby,
                      title: 'First Wing',
                      description: 'Submit your first wing review',
                      isUnlocked: totalReviews >= 1,
                      progress: totalReviews >= 1 ? 1.0 : 0.0,
                    ),
                    
                    _buildAchievementCard(
                      context,
                      icon: FontAwesomeIcons.fire,
                      title: 'Wing Warrior',
                      description: 'Submit 5 wing reviews',
                      isUnlocked: totalReviews >= 5,
                      progress: totalReviews >= 5 ? 1.0 : totalReviews / 5.0,
                    ),
                    
                    _buildAchievementCard(
                      context,
                      icon: FontAwesomeIcons.crown,
                      title: 'Wing Commander',
                      description: 'Submit 25 wing reviews',
                      isUnlocked: totalReviews >= 25,
                      progress: totalReviews >= 25 ? 1.0 : totalReviews / 25.0,
                    ),
                    
                    _buildAchievementCard(
                      context,
                      icon: FontAwesomeIcons.beerMugEmpty,
                      title: 'Beer Connoisseur',
                      description: 'Rate beer at 10 different locations',
                      isUnlocked: false, // TODO: Implement location-based tracking
                      progress: 0.0,
                    ),
                    
                    _buildAchievementCard(
                      context,
                      icon: FontAwesomeIcons.heart,
                      title: 'Community Favorite',
                      description: 'Get 10 likes on your reviews',
                      isUnlocked: false, // TODO: Implement likes system
                      progress: 0.0,
                    ),

                    const SizedBox(height: 24),

                    // Leaderboard section
                    Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.rankingStar,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Top Reviewers This Month',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildLeaderboardItem(context, 'WingMaster42', 47, 1, true),
                            _buildLeaderboardItem(context, 'BeerLover99', 35, 2, false),
                            _buildLeaderboardItem(context, 'SpiceQueen', 28, 3, false),
                            _buildLeaderboardItem(context, 'CrispyKing', 22, 4, false),
                            _buildLeaderboardItem(context, '${authService.currentUserName ?? 'You'}', totalReviews, 5, false, isCurrentUser: true),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        FaIcon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isUnlocked,
    required double progress,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(
                icon,
                color: isUnlocked ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUnlocked ? null : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              FaIcon(
                FontAwesomeIcons.checkCircle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    String name,
    int reviews,
    int position,
    bool isTop, {
    bool isCurrentUser = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop
                  ? Colors.amber
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          ),
          Text(
            '$reviews reviews',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  int _getLevel(int reviews) {
    if (reviews >= 50) return 5;
    if (reviews >= 25) return 4;
    if (reviews >= 10) return 3;
    if (reviews >= 5) return 2;
    return 1;
  }
}
