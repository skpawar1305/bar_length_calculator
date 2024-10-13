import 'package:flutter/material.dart';

void main() {
  runApp(RectangleBarLengthCalculator());
}

class RectangleBarLengthCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rectangle Bar Length Calculator',
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
      barsX = (length / spacing) * breadth;
      barsY = (breadth / spacing) * length;
      totalBarsLength = barsX + barsY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rectangle Bar Length Calculator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            CustomPaint(
              size: Size(300, 200),
              painter: RectanglePainter(length: length, breadth: breadth, spacing: spacing),
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

  RectanglePainter({required this.length, required this.breadth, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final aspectRatio = length / breadth;
    final scaleWidth = size.width - 20;
    final scaleHeight = scaleWidth / aspectRatio;

    final rect = Rect.fromLTWH(10, 10, scaleWidth, scaleHeight);
    canvas.drawRect(rect, paint);

    _drawBars(canvas, rect, size);
  }

  void _drawBars(Canvas canvas, Rect rect, Size size) {
    final barPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    // Bars along X-axis
    for (double i = rect.left; i <= rect.right; i += spacing * rect.width / length) {
      canvas.drawLine(Offset(i, rect.top), Offset(i, rect.bottom), barPaint);
    }

    // Bars along Y-axis
    for (double i = rect.top; i <= rect.bottom; i += spacing * rect.height / breadth) {
      canvas.drawLine(Offset(rect.left, i), Offset(rect.right, i), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
