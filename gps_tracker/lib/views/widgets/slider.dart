import 'package:flutter/material.dart';

class Slider extends StatelessWidget{
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>onChanged;

  const Slider({super.key, 
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged, required int divisions,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}