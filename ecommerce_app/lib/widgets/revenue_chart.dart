import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Revenue generated',
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
                    'Daily',
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
        const SizedBox(height: 24),
        
        // Chart Area
        Container(
          height: 300,
          child: CustomPaint(
            size: const Size(double.infinity, 300),
            painter: BarChartPainter(),
          ),
        ),
      ],
    );
  }
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final barWidth = size.width / 9;
    final maxHeight = size.height - 40;
    
    // Sample data (heights as percentages)
    final data = [0.6, 0.8, 0.4, 0.9, 0.7, 0.3, 0.6];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    for (int i = 0; i < data.length; i++) {
      final x = i * (barWidth + 10) + 20;
      final barHeight = maxHeight * data[i];
      final y = size.height - barHeight - 20;
      
      // Bar
      paint.color = i == 3 ? Colors.black : Colors.grey.shade300; // Highlight Wednesday
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth - 10, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
      
      // Day labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - 10 - textPainter.width) / 2, size.height - 15),
      );
    }
    
    // Highlight value
    final highlightPainter = TextPainter(
      text: const TextSpan(
        text: 'N180,000',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    highlightPainter.layout();
    highlightPainter.paint(
      canvas,
      Offset(3 * (barWidth + 10) + 10, size.height - maxHeight * 0.9 - 35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
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