import 'package:flutter/material.dart';

class TransactionChart extends StatelessWidget {
  const TransactionChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaction volume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Monthly',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Text(
          'NGN 500,000',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // Chart Area
        Container(
          height: 200,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: TransactionLineChartPainter(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Legend
        Row(
          children: [
            _buildLegendItem('Wednesday', Colors.purple, '60'),
            const SizedBox(width: 16),
            _buildLegendItem('Current', Colors.blue, 'N40,000'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class TransactionLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path1 = Path();
    final path2 = Path();
    
    // Sample data points
    final points1 = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];
    
    final points2 = [
      Offset(0, size.height * 0.9),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.6),
    ];
    
    // Draw first line (purple)
    paint.color = Colors.purple;
    path1.moveTo(points1[0].dx, points1[0].dy);
    for (int i = 1; i < points1.length; i++) {
      path1.lineTo(points1[i].dx, points1[i].dy);
    }
    canvas.drawPath(path1, paint);
    
    // Draw second line (blue)
    paint.color = Colors.blue;
    path2.moveTo(points2[0].dx, points2[0].dy);
    for (int i = 1; i < points2.length; i++) {
      path2.lineTo(points2[i].dx, points2[i].dy);
    }
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}