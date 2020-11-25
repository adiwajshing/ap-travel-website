import 'package:flutter/material.dart';

class MySlider extends StatelessWidget {
  final int value, minValue, maxValue;
  final void Function(double) onChanged;

  MySlider({this.value, this.onChanged, this.minValue = 1, this.maxValue = 25});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        inactiveTrackColor: Color(0xFF8D8E98),
        activeTrackColor: Colors.black,
        thumbColor: Theme.of(context).accentColor,
        overlayColor: Theme.of(context).accentColor.withOpacity(0.2),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
      ),
      child: Slider(
        value: value.toDouble(),
        onChanged: onChanged,
        min: minValue.toDouble(),
        max: maxValue.toDouble(),
      ),
    );
  }
}
