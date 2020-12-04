import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog(
      {Key key,
      this.items,
      this.initialSelectedValues,
      this.initialSelectedLabels})
      : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;
  final List initialSelectedLabels;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = <V>{};
  final _selectedLabels = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
      _selectedLabels.addAll(widget.initialSelectedLabels);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked, String label) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
        _selectedLabels.add(label);
      } else {
        _selectedValues.remove(itemValue);
        _selectedLabels.remove(label);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(
        context, {'index': _selectedValues, 'values': _selectedLabels});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Text('Select Tags\n'),
          widget.initialSelectedLabels != null &&
              widget.initialSelectedLabels.isNotEmpty
              ? Wrap(
            spacing: 5,
            runSpacing: 10,
            direction: Axis.horizontal,
            children: widget.initialSelectedLabels
                .map((e) => Chip(
              label: Text(e as String,style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600]
              ),),
              padding: EdgeInsets.all(5),
            ))
                .toList(),
          )
              : SizedBox.shrink(),
        ],
      ),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL',
              style: TextStyle(color: Theme.of(context).hintColor)),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text(
            'OK',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) =>
          _onItemCheckedChange(item.value, checked, item.label),
    );
  }
}
