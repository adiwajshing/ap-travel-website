import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class AddButton extends StatefulWidget {
  final int width;
  final int height;
  final String addText;
  final int maxValue;
  final Function(int) onChanged;

  AddButton({
    this.addText = 'ADD',
    this.height,
    this.onChanged,
    this.maxValue,
    this.width,
  });

  @override
  _AddButtonState createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  int count = 0;

  void increment() => setState(() {
        count++;
        return widget.onChanged(count);
      });

  void decrement() => setState(() {
        count--;
        return widget.onChanged(count);
      });

  void showToast() {
    toast('You have already selected maximum rooms of this type');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height?.toDouble(),
      width: widget.width?.toDouble(),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: count == 0 ? Color(0xFFFF7230) : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.deepOrange),
        ),
        child: Row(
          children: [
            count == 0
                ? SizedBox.shrink()
                : _buildButton(
                    onTap: decrement,
                    iconData: Icons.remove,
                  ),
            Expanded(
              child: InkWell(
                onTap: () => count == 0
                    ? count == widget.maxValue
                        ? showToast()
                        : increment()
                    : null,
                child: Text(
                  count == 0 ? widget.addText : count.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: count == 0 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            _buildButton(
              onTap: count == widget.maxValue ? showToast : increment,
              iconData: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Container _buildButton({
    @required VoidCallback onTap,
    @required IconData iconData,
  }) {
    return Container(
      color: Colors.deepOrange,
      alignment: Alignment.center,
      width: 30,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(iconData, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
