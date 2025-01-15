import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(RectangleBarLengthCalculator());
}

class RectangleBarLengthCalculator extends StatelessWidget {
  const RectangleBarLengthCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), // Override system font scaling
      child: MaterialApp(
        title: 'Bar Length Calculator in Rectangular Slab',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const CalculatorPage(),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  double length = 58.2;
  double breadth = 5.2;
  double spacingX = 0.25;
  double spacingY = 0.25;
  bool useSeparateSpacing = false;

  double density = 7850.0; // Steel density in kg/m³
  double diameter = 8.0; // Default diameter in mm
  double barsX = 0.0;
  double barsY = 0.0;
  double totalBarsLength = 0.0;
  double totalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPersistentValues();
    _updateValues();
  }

  Future<void> _loadPersistentValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      density = prefs.getDouble('density') ?? density;
      diameter = prefs.getDouble('diameter') ?? diameter;
      length = prefs.getDouble('length') ?? length;
      breadth = prefs.getDouble('breadth') ?? breadth;
      spacingX = prefs.getDouble('spacingX') ?? spacingX;
      spacingY = prefs.getDouble('spacingY') ?? spacingY;
      useSeparateSpacing = prefs.getBool('useSeparateSpacing') ?? useSeparateSpacing;
    });
  }

  Future<void> _savePersistentValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('density', density);
    await prefs.setDouble('diameter', diameter);
    await prefs.setDouble('length', length);
    await prefs.setDouble('breadth', breadth);
    await prefs.setDouble('spacingX', spacingX);
    await prefs.setDouble('spacingY', spacingY);
    await prefs.setBool('useSeparateSpacing', useSeparateSpacing);
  }

  void _updateValues() {
    setState(() {
      if (length < 0 || breadth < 0 || spacingX < 0 || spacingY < 0) {
        return;
      }
      barsX = (length / spacingX) * breadth;
      barsY = (breadth / spacingY) * length;
      totalBarsLength = barsX + barsY;

      // Calculate weight (π * d² / 4) * length * density
      final radius = diameter / 1000 / 2; // Convert diameter to meters
      final area = pi * radius * radius; // Cross-sectional area in m²
      totalWeight = area * totalBarsLength * density;

      // Save values persistently
      _savePersistentValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus the text field when tapping outside
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5),
                CustomPaint(
                  size: const Size(300, 150),
                  painter: RectanglePainter(
                    length: length,
                    breadth: breadth,
                    spacingX: spacingX,
                    spacingY: spacingY,
                    useSeparateSpacing: useSeparateSpacing,
                    totalBarsLength: totalBarsLength,
                  ),
                ),
                const SizedBox(height: 5),
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
                      SwitchListTile(
                        title: const Text('Use separate spacing for X and Y'),
                        value: useSeparateSpacing,
                        onChanged: (value) {
                          setState(() {
                            useSeparateSpacing = value;
                            _updateValues();
                          });
                        },
                      ),
                      if (useSeparateSpacing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: _buildNumberInput('Spacing X (m):', spacingX, (value) {
                                spacingX = value;
                                _updateValues();
                              }),
                            ),
                            SizedBox(width: 10), // Add spacing between the inputs
                            Flexible(
                              child: _buildNumberInput('Spacing Y (m):', spacingY, (value) {
                                spacingY = value;
                                _updateValues();
                              }),
                            ),
                          ],
                        )
                      else
                        _buildNumberInput('Spacing (m):', spacingX, (value) {
                          spacingX = value;
                          spacingY = value;
                          _updateValues();
                        }),
                      _buildNumberInput('Density (kg/m³):', density, (value) {
                        density = value;
                        _updateValues();
                      }),
                      DropdownButton<double>(
                        value: diameter,
                        items: [8.0, 10.0].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text('$value mm'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              diameter = value;
                              _updateValues();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Text('Bars on X-axis: ${barsX.toStringAsFixed(2)} m'),
                      Text('Bars on Y-axis: ${barsY.toStringAsFixed(2)} m'),
                      Text('Total length required: ${totalBarsLength.toStringAsFixed(2)} m'),
                      Text('Total weight: ${totalWeight.toStringAsFixed(2)} kg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        const SizedBox(height: 10),
      ],
    );
  }
}

class RectanglePainter extends CustomPainter {
  final double length;
  final double breadth;
  final double spacingX;
  final double spacingY;
  final bool useSeparateSpacing;
  final double totalBarsLength;

  RectanglePainter({
    required this.length,
    required this.breadth,
    required this.spacingX,
    required this.spacingY,
    required this.useSeparateSpacing,
    required this.totalBarsLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final aspectRatio = length / breadth;
    final widthFactor = (size.width - 20) / length;
    final heightFactor = (size.height - 20) / breadth;
    final scaleFactor = widthFactor < heightFactor ? widthFactor : heightFactor;
    final scaleWidth = length * scaleFactor;
    final scaleHeight = breadth * scaleFactor;

    final offsetX = (size.width - scaleWidth) / 2;
    final offsetY = (size.height - scaleHeight) / 2;
    final rect = Rect.fromLTWH(offsetX, offsetY, scaleWidth, scaleHeight);
    canvas.drawRect(rect, paint);

    if (totalBarsLength > 1000) {
      // Fill the rectangle if the conditions are not met
      final fillPaint = Paint()
        ..color = Colors.black.withOpacity(0.3) // Choose a fill color with some transparency
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, fillPaint);
      return;
    }

    if (length > 0 && breadth > 0) {
      final spacingXFactor = useSeparateSpacing ? spacingX : spacingX;
      final spacingYFactor = useSeparateSpacing ? spacingY : spacingX;

      for (double y = rect.top;
          y <= rect.bottom;
          y += spacingYFactor * rect.height / breadth) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
      }

      for (double x = rect.left;
          x <= rect.right;
          x += spacingXFactor * rect.width / length) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
