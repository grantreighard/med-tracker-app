import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

void main() {
  runApp(MedTracker());
}

class MedTracker extends StatefulWidget {
  @override
  _MedTrackerState createState() => _MedTrackerState();
}

class MedEntry {
  DateTime dateTime;
  String medication;

  MedEntry(this.dateTime, this.medication);

  @override
  String toString() {
    return '{ ${this.dateTime}, ${this.medication} }';
  }
}

GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

class _MedTrackerState extends State<MedTracker> {
  DateTime dateTime = DateTime.now();
  String medication = '';
  AutoCompleteTextField textField;
  bool isAdding = false;
  List<MedEntry> entries = [];

  _MedTrackerState() {
    textField = AutoCompleteTextField<String>(
      textChanged: (text) {
        setState(() {
          medication = text;
        });
      },
      suggestions: entries.map((entry) => entry.medication).toList(),
      itemFilter: (suggestion, input) =>
          suggestion.toLowerCase().startsWith(input.toLowerCase()),
      onFocusChanged: (hasFocus) {},
      decoration: new InputDecoration(
        hintText: "Medication name:",
        suffixIcon: new Icon(Icons.search),
      ),
      itemBuilder: (context, suggestion) => new Padding(
          child: new ListTile(title: new Text(suggestion)),
          padding: EdgeInsets.all(8.0)),
    );
  }

  void addEntryAndCloseForm() {
    // textField.triggerSubmitted();
    print(medication);
    setState(() {
      entries.add(MedEntry(dateTime, medication));
      isAdding = false;
      medication = '';
    });

    textField
        .updateSuggestions(entries.map((entry) => entry.medication).toList());
  }

  List<Widget> getForm() {
    print(entries.map((entry) => entry.medication).toList());
    if (isAdding) {
      setState(() {
        dateTime = DateTime.now();
      });

      return [
        AlertDialog(
          content: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Add a medication entry'),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        isAdding = false;
                      });
                    },
                    child: isAdding
                        ? Icon(
                            Icons.close,
                            color: Colors.red,
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 300,
                child: CupertinoDatePicker(
                    initialDateTime: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        dateTime = newDate;
                      });
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: textField,
                  ),
                  FlatButton(
                      onPressed: () => addEntryAndCloseForm(),
                      child: Icon(Icons.add))
                ],
              ),
            ],
          ),
        )
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          key: key,
          appBar: AppBar(
            title: Text('Simple Medication Tracker'),
            backgroundColor: Colors.lightGreen,
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: isAdding
                          ? Text('')
                          : FlatButton(
                              child: Text('Add a medication entry'),
                              onPressed: () {
                                setState(() {
                                  isAdding = true;
                                });
                              },
                            ),
                    ),
                  ],
                ),
                Column(
                  children: getForm(),
                ),
                Column(children: [
                  entries.length > 0 ? Text('Medication Entries') : Text(''),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];

                        return Dismissible(
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: Text('Delete'),
                          ),
                          key: Key(entry.medication),
                          child: ListTile(
                            title:
                                Text('${entry.medication} ${entry.dateTime}'),
                          ),
                          onDismissed: (direction) {
                            setState(() {
                              entries.removeAt(index);
                            });
                          },
                        );
                      },
                    ),
                  )
                ]),
              ],
            ),
          )),
    );
  }
}
