import 'package:flutter/material.dart';

class PendingReviews extends StatelessWidget {
  const PendingReviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildReviewItem(
          username: '@Karyin',
          action: 'just made a new listing',
          time: '30 mins ago',
        ),
        const SizedBox(height: 16),
        
        _buildReviewItem(
          username: '',
          action: 'A new product was listed',
          time: '1 hour ago',
        ),
        const SizedBox(height: 16),
        
        _buildReviewItem(
          username: '@Michael',
          action: 'just made a swap request',
          time: '3 hours ago',
        ),
        const SizedBox(height: 16),
        
        _buildReviewItem(
          username: '@Peru',
          action: 'just made a swap request',
          time: '6 hours ago',
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String username,
    required String action,
    required String time,
  }) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    if (username.isNotEmpty) ...[
                      TextSpan(
                        text: username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(text: ' '),
                    ],
                    TextSpan(
                      text: action,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Review Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Review',
            style: TextStyle(
              color: Colors.pink.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}