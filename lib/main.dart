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

  List<String> getAmOrPm(int twentyFour) {
    String amOrPm = 'am';
    String hour = '$twentyFour';

    if (twentyFour >= 12) {
      amOrPm = 'pm';
    }

    if (twentyFour > 12) {
      hour = '${twentyFour - 12}';
    }

    if (twentyFour == 0) {
      hour = '12';
    }

    return [hour, amOrPm];
  }

  String getFormattedDate(DateTime dateTime) {
    List<String> hourAndAmOrPm = getAmOrPm(dateTime.hour);
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${hourAndAmOrPm[0]}:${dateTime.minute}:${dateTime.second} ${hourAndAmOrPm[1]}';
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: getForm(),
                ),
                Column(
                  children: [
                    !isAdding
                        ? entries.length > 0
                            ? Text('Medication entries')
                            : Text('Add an entry to get started')
                        : Text(''),
                    SizedBox(
                      height: 300,
                      child: isAdding
                          ? null
                          : ListView.builder(
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];

                                return Dismissible(
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    color: Colors.red,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Text('Delete'),
                                    ),
                                  ),
                                  key: Key(entry.medication),
                                  child: ListTile(
                                    title: Text(
                                        '${entry.medication} ${getFormattedDate(entry.dateTime)}'),
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
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: FloatingActionButton(
                          backgroundColor: Colors.lightGreen,
                          child: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              isAdding = true;
                            });
                          }),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
