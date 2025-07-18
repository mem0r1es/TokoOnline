import 'package:flutter/material.dart';

class DashboardStats extends StatelessWidget {
  final String userType;

  const DashboardStats({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total users',
            value: '2,000',
            change: '+120 this month',
            changePositive: true,
            icon: Icons.people,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Active orders',
            value: '280',
            change: '+200 this month',
            changePositive: true,
            icon: Icons.shopping_cart,
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Transaction count',
            value: '600',
            change: '+20 this month',
            changePositive: true,
            icon: Icons.receipt,
            iconColor: Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Total revenue generated',
            value: 'N100,00',
            change: '+N20,000 this month',
            changePositive: true,
            icon: Icons.attach_money,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool changePositive,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                changePositive ? Icons.trending_up : Icons.trending_down,
                color: changePositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: changePositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}