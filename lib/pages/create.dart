import 'dart:async';
import 'dart:convert';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:testproj/pages/create2.dart';
import 'package:testproj/util/models.dart';
import 'package:http/http.dart' as http;

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  var gameData = "";
  DateTime? dayD = DateTime.now();
  TimeOfDay? timeD = TimeOfDay.now();
  Duration? durationD = Duration(hours: 1);
  DateTime? endData;
  DateTime? startData;
  int maxData = 4;

  onGame(String game) {
    gameData = game;
  }

  onDate({day, time, duration}) {
    if (day != null) {
      dayD = day;
    } else if (time != null) {
      timeD = time;
    } else if (duration != null) {
      durationD = duration;
    }
  }

  onMaxChange(value) {
    maxData = value;
  }

  onSubmit() {
    if (dayD != null &&
        timeD != null &&
        durationD != null &&
        durationD!.compareTo(Duration.zero) != 0 &&
        gameData != "") {
      startData = DateTime(
          dayD!.year, dayD!.month, dayD!.day, timeD!.hour, timeD!.minute);
      endData = startData!.add(durationD!);
      print(startData);
      print(endData);
      Navigator.push(
        context,
        PageTransition(
          child: SelectGroupScreen(
              startData: startData,
              endData: endData,
              gameData: gameData,
              maxData: maxData,
              groups: Provider.of<List<GroupModel>>(context, listen: false),
              username:
                  Provider.of<UserModel>(context, listen: false).username),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 200),
          reverseDuration: Duration(milliseconds: 200),
        ),
      );
    } else {
      var snackbartext;
      if (gameData == "") {
        snackbartext = "Choose a game to continue";
      } else if (durationD == null ||
          durationD!.compareTo(Duration.zero) == 0) {
        snackbartext = "Choose a session duration to continue";
      }
      var snackbar = SnackBar(
          content: Text(snackbartext),
          // padding: EdgeInsets.all(8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          backgroundColor: Theme.of(context).colorScheme.surface);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 28, right: 28),
        child: Column(
          children: [
            CustomAppBar(onSubmit),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DateSelector(dateFunction: onDate),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: MaxSelector(onChange: onMaxChange),
                    ),
                    GameSelector(gameFunction: onGame),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MaxSelector extends StatefulWidget {
  const MaxSelector({Key? key, this.onChange}) : super(key: key);
  final onChange;

  @override
  _MaxSelectorState createState() => _MaxSelectorState();
}

class _MaxSelectorState extends State<MaxSelector> {
  int _currentValue = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: 15.0, left: 12.0, bottom: 12.0, right: 12.0),
          child: Row(
            children: [
              Text(
                "Max Players",
                style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              )
            ],
          ),
        ),
        Row(children: [
          Expanded(
            child: NumberPicker(
              infiniteLoop: true,
              haptics: true,
              value: _currentValue,
              minValue: 2,
              maxValue: 15,
              axis: Axis.horizontal,
              itemWidth: 50,
              selectedTextStyle: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textStyle: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              onChanged: (value) {
                widget.onChange(value);
                setState(() => _currentValue = value);
              },
            ),
          ),
        ])
      ],
    ));
  }
}

class DateSelector extends StatefulWidget {
  const DateSelector({Key? key, required this.dateFunction}) : super(key: key);
  final Function dateFunction;

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  var dayData;
  var timeData;
  var durationData;
  var start;
  var end;
  onDate(day) {
    dayData = day;
    widget.dateFunction(day: dayData);
  }

  onTime(time) {
    timeData = time;
    widget.dateFunction(time: timeData);
  }

  onDuration(duration) {
    durationData = duration;
    widget.dateFunction(duration: durationData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: 15.0, left: 12.0, bottom: 12.0, right: 12.0),
          child: Row(
            children: [
              Text(
                "Time",
                style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DateButton(dateFunction: onDate),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TimeButton(timeFunction: onTime),
            Text(
              "for",
              style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            TimeButton2(durationFunction: onDuration),
          ],
        ),
      ],
    ));
  }
}

class TimeButton extends StatefulWidget {
  TimeButton({required this.timeFunction});
  final Function timeFunction;

  @override
  _TimeButtonState createState() => _TimeButtonState();
}

class _TimeButtonState extends State<TimeButton> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        widget.timeFunction(selectedTime);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextButton.icon(
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 28,
          ),
          style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 16.0, right: 12.0),
              primary: Theme.of(context).colorScheme.primary,
              textStyle: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              )),
          label: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${selectedTime.hourOfPeriod == 0 ? "12" : selectedTime.hourOfPeriod}:${selectedTime.minute < 10 ? "0" + selectedTime.minute.toString() : selectedTime.minute} ${selectedTime.period.index == 0 ? "AM" : "PM"}',
            ),
          ),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }
}

class TimeButton2 extends StatefulWidget {
  TimeButton2({required this.durationFunction});
  final Function durationFunction;

  @override
  _TimeButton2State createState() => _TimeButton2State();
}

class _TimeButton2State extends State<TimeButton2> {
  Duration selectedTime = Duration(hours: 1);

  Future<void> _selectDate(BuildContext context) async {
    final Duration? picked =
        await showDurationPicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        widget.durationFunction(selectedTime);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextButton.icon(
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 28,
          ),
          style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 16.0, right: 12.0),
              primary: Theme.of(context).colorScheme.primary,
              textStyle: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              )),
          label: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${selectedTime.inMinutes ~/ 60 == 0 ? "" : (selectedTime.inMinutes ~/ 60).toString() + " hr "}${selectedTime.inMinutes % 60 == 0 ? "" : (selectedTime.inMinutes % 60).toString() + " min"}',
            ),
          ),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }
}

class DateButton extends StatefulWidget {
  DateButton({required this.dateFunction});
  final Function dateFunction;

  @override
  _DateButtonState createState() => _DateButtonState();
}

class _DateButtonState extends State<DateButton> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        lastDate: DateTime(
            DateTime.now().add(Duration(days: 7)).year,
            DateTime.now().add(Duration(days: 7)).month,
            DateTime.now().add(Duration(days: 7)).day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        widget.dateFunction(selectedDate);
      });
  }

  static List weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextButton.icon(
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 28,
          ),
          style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 16.0, right: 12.0),
              primary: Theme.of(context).colorScheme.primary,
              textStyle: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              )),
          label: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${selectedDate.toLocal().day} ${weekdays[selectedDate.toLocal().weekday - 1]}',
            ),
          ),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }
}

class GameSelector extends StatefulWidget {
  const GameSelector({Key? key, required this.gameFunction}) : super(key: key);
  final Function gameFunction;

  @override
  _GameSelectorState createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  onItemChanged(String value) {
    print("hello");
    if (debounceTimer != null) {
      debounceTimer?.cancel();
    }
    debounceTimer = Timer(Duration(milliseconds: 500), () {
      print('searcihng');
      if (this.mounted && _textController.text != textfromC) {
        textfromC = _textController.text;
        fetchResults(_textController.text);
      }
    });
    // setState(() {});
  }

  _GameSelectorState() {}

  var current = "";
  onSelect(RadioModel value) {
    setState(() {
      current = value.isSelected ? value.text : "";
      print(current);
      widget.gameFunction(current);
    });
  }

  TextEditingController _textController = TextEditingController();
  bool _isSearching = false;
  String? _error;
  var results = [];

  Timer? debounceTimer;
  var textfromC = "";
  // Future checkControl() async {
  //   if (widget.controller.text.length > 0) {
  //     await Future.delayed(Duration(milliseconds: 500));
  //     final request = await fetchResults(widget.controller.text);

  //   }
  // }

  void fetchResults(String text) async {
    if (text.isEmpty) {
      setState(() {
        _isSearching = false;
        _error = null;
        results = [];
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _error = null;
      results = [];
    });
    var result = await http.post(Uri.parse("https://api.igdb.com/v4/games"),
        headers: <String, String>{
          'Client-ID': 'vg3tdr0chb97oygbkjej7et29m1er3',
          'Authorization': 'Bearer hxam8pj5gmq0vaeep22o2wxuds439i'
        },
        body: 'fields name; search "${text.trim()}";');
    List parsed = jsonDecode(result.body).cast<Map<String, dynamic>>();
    if (this.mounted && _textController.text == text) {
      setState(() {
        _isSearching = false;
        if (result.statusCode == 200) {
          results =
              parsed.map((value) => RadioModel(false, value['name'])).toList();
          print(results);
        } else {
          _error = 'No results';
          print(_error);
          print(result.body);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context);
    var data = user.recents.map((e) => RadioModel(false, e)).toList();
    print("state" + results.toString());
    return Column(
      children: [
        SearchBox(
          onFilter: onItemChanged,
          textController: _textController,
          current: current,
        ),
        SizedBox(
          height: 5,
        ),
        GameList(
          controller: _textController,
          data: data,
          data2: results,
          isSearch: _isSearching,
          onChange: onSelect,
        ),
      ],
    );
  }
}

class GameList extends StatefulWidget {
  const GameList(
      {Key? key,
      required this.controller,
      required this.data,
      required this.onChange,
      required this.data2,
      required this.isSearch})
      : super(key: key);
  final TextEditingController controller;
  final data;
  final Function onChange;
  final data2;
  final isSearch;
  @override
  _GameListState createState() => _GameListState(data);
}

class _GameListState extends State<GameList> {
  _GameListState(this.datainit) {}
  final datainit;
  var data;
  @override
  void initState() {
    super.initState();
    data = datainit;
  }

  @override
  Widget build(BuildContext context) {
    var data2 = widget.data2;
    print("h" + data2.toString());
    return Container(
      child: widget.controller.text.length > 0 && widget.isSearch == false
          ? ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.data2.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(top: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        // data.forEach((element) => element.isSelected = false);
                        if (widget.data2[index].isSelected) {
                          widget.data2[index].isSelected =
                              !widget.data2[index].isSelected;
                        } else {
                          widget.data2
                              .forEach((element) => element.isSelected = false);
                          widget.data2[index].isSelected = true;
                        }
                        widget.onChange(widget.data2[index]);
                      });
                    },
                    child: LabeledRadio(item: widget.data2[index]),
                  ),
                );
              },
            )
          : widget.controller.text.length > 0 && widget.isSearch == true
              ? Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            // data.forEach((element) => element.isSelected = false);
                            if (data[index].isSelected) {
                              data[index].isSelected = !data[index].isSelected;
                            } else {
                              data.forEach(
                                  (element) => element.isSelected = false);
                              data[index].isSelected = true;
                            }
                            widget.onChange(data[index]);
                          });
                        },
                        child: LabeledRadio(item: data[index]),
                      ),
                    );
                  },
                ),
    );
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({Key? key, required this.item}) : super(key: key);

  final RadioModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: item.isSelected
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : BoxDecoration(),
      child: Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12, left: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              child: item.isSelected
                  ? Icon(Icons.check,
                      color: Theme.of(context).colorScheme.primary)
                  : Icon(LineIcons.plus,
                      size: 29, color: Theme.of(context).colorScheme.primary),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(
                  item.text,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String text;

  RadioModel(this.isSelected, this.text);
}

class CustomAppBar extends StatefulWidget {
  final onSubmit;
  CustomAppBar(this.onSubmit);
  // final onTodayPress;
  // CustomAppBar(this.onTodayPress);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Create Session",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CheckButton(widget.onSubmit),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckButton extends StatefulWidget {
  final onSubmit;
  CheckButton(this.onSubmit);

  // final onTodayPress;
  // GreenButton(this.onTodayPress);

  @override
  _CheckButtonState createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47.0,
      width: 47.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            // customBorder: ,
            child: Icon(
              Icons.arrow_forward,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
            // splashColor: Color(0xff000000),
            onTap: widget.onSubmit,
          ),
        ),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  SearchBox(
      {Key? key,
      required this.onFilter,
      required this.textController,
      required this.current})
      : super(key: key);
  final onFilter;
  final textController;
  final current;

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: TextField(
        readOnly: widget.current == "" ? false : true,
        style: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: widget.current == "" ? 'Game' : widget.current,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          hintStyle: GoogleFonts.poppins(
            color: widget.current == ""
                ? Theme.of(context).colorScheme.onBackground
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
          focusColor: Theme.of(context).colorScheme.primary,
          border: InputBorder.none,
        ),
        controller: widget.textController,
        onChanged: widget.onFilter,
        cursorColor: Theme.of(context).colorScheme.primary,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
