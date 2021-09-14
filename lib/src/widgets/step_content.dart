import 'package:flutter/material.dart';

import 'wizard_screen.dart' show Type;

class StepContent extends StatelessWidget {
  StepContent({
    required this.lines,
    required this.type,
    required this.updateValue,
    required this.toggleLinkSelection,
    required this.updateKey,
  });

  final Map<List<String>, List<bool>> lines;
  final Type type;
  final Function updateValue, toggleLinkSelection, updateKey;

  @override
  Widget build(BuildContext context) {
    var customText = '';
    return Column(
      children: lines
          .map(
            (key, _value) => MapEntry(
                key,
                ListTile(
                  tileColor: Colors.transparent,
                  title: SelectableText(
                    key[0],
                    onSelectionChanged: (selection, cause) {
                      print(selection.start);
                      print(selection.end);
                      final selectedText =
                          key[0].substring(selection.start, selection.end);
                      print(selectedText);
                      customText = selectedText;
                    },
                    toolbarOptions: ToolbarOptions(),
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Checkbox(
                          value: _value[0],
                          onChanged: (newVal) {
                            updateValue(type, [newVal!, _value[1]], key);
                          },
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: IconButton(
                          color: !_value[1] ? Colors.grey[300] : Colors.blue,
                          icon: Icon(Icons.add_link),
                          onPressed: () {
                            toggleLinkSelection(type, _value, key);
                          },
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: IconButton(
                          color: Colors.amberAccent,
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            if (customText.isNotEmpty) {
                              print(customText);
                              updateKey(type, key, customText);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          )
          .values
          .toList(),
    );
  }
}
