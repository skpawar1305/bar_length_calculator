import 'package:flutter/material.dart';

void main() {
  runApp(RectangleBarLengthCalculator());
}

class RectangleBarLengthCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Length Calculator in Rectangular Slab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  double length = 58.2;
  double breadth = 5.2;
  double spacing = 0.25;

  double barsX = 0.0;
  double barsY = 0.0;
  double totalBarsLength = 0.0;

  @override
  void initState() {
    super.initState();
    _updateValues();
  }

  void _updateValues() {
    setState(() {
      if (length < 0 || breadth < 0 || spacing < 0) {
        return;
      }
      barsX = (length / spacing) * breadth;
      barsY = (breadth / spacing) * length;
      totalBarsLength = barsX + barsY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bar Length Calculator in Rectangular Slab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            CustomPaint(
              size: Size(300, 150), // Fixed width of 300 and max height of 150
              painter: RectanglePainter(
                length: length,
                breadth: breadth,
                spacing: spacing,
                totalBarsLength: totalBarsLength,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildNumberInput('Length (m):', length, (value) {
                    length = value;
                    _updateValues();
                  }),
                  _buildNumberInput('Breadth (m):', breadth, (value) {
                    breadth = value;
                    _updateValues();
                  }),
                  _buildNumberInput('Spacing (m):', spacing, (value) {
                    spacing = value;
                    _updateValues();
                  }),
                  SizedBox(height: 10),
                  Text('Bars on X-axis: ${barsX.toStringAsFixed(2)} m'),
                  Text('Bars on Y-axis: ${barsY.toStringAsFixed(2)} m'),
                  Text('Total length required: ${totalBarsLength.toStringAsFixed(2)} m'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput(String label, double initialValue, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: initialValue.toString(),
          ),
          onChanged: (value) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null) {
              onChanged(parsedValue);
            }
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class RectanglePainter extends CustomPainter {
  final double length;
  final double breadth;
  final double spacing;
  final double totalBarsLength;

  RectanglePainter({
    required this.length,
    required this.breadth,
    required this.spacing,
    required this.totalBarsLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Calculate aspect ratio
    final aspectRatio = length / breadth;

    // Calculate the scaling factor for width and height
    final widthFactor = (size.width - 20) / length; // Leave some padding
    final heightFactor = (size.height - 20) / breadth; // Leave some padding

    // Choose the smaller scaling factor to ensure the rectangle fits
    final scaleFactor = widthFactor < heightFactor ? widthFactor : heightFactor;

    // Scale width and height proportionally
    final scaleWidth = length * scaleFactor;
    final scaleHeight = breadth * scaleFactor;

    // Draw the rectangle centered in the canvas
    final offsetX = (size.width - scaleWidth) / 2;
    final offsetY = (size.height - scaleHeight) / 2;
    final rect = Rect.fromLTWH(offsetX, offsetY, scaleWidth, scaleHeight);
    canvas.drawRect(rect, paint);

    if (length > 0 && breadth > 0 && spacing >= 0.001 && totalBarsLength < 100000) {
      _drawBars(canvas, rect, size);
    } else {
      // Fill the rectangle if the conditions are not met
      final fillPaint = Paint()
        ..color = Colors.black.withOpacity(0.3) // Choose a fill color with some transparency
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, fillPaint);
    }
  }

  void _drawBars(Canvas canvas, Rect rect, Size size) {
    final barPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    // Calculate the maximum number of bars based on the available space
    int maxBarsX = (rect.height / (spacing * rect.height / breadth)).floor();
    int maxBarsY = (rect.width / (spacing * rect.width / length)).floor();

    // Bars along X-axis
    for (int i = 0; i <= maxBarsX; i++) {
      double y = rect.top + i * (spacing * rect.height / breadth);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), barPaint);
    }

    // Bars along Y-axis
    for (int i = 0; i <= maxBarsY; i++) {
      double x = rect.left + i * (spacing * rect.width / length);
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
