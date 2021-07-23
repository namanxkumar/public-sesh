import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:testproj/pages/sessions-postpage.dart';
import 'package:testproj/util/firestore.dart';
import 'package:testproj/util/models.dart';
import 'package:testproj/widgets/creationaware.dart';
import 'package:testproj/widgets/homelistitem.dart';
import 'package:page_transition/page_transition.dart';

class SessionsScreen extends StatefulWidget {
  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  onTodayPress() {
    changeCalendar(0);
    if (fixedExtentScrollController.hasClients) {
      fixedExtentScrollController.jumpTo(0.0);
    }
  }

  FixedExtentScrollController fixedExtentScrollController =
      new FixedExtentScrollController();
  var currentDate = 0;
  var todaybutton = 1;

  changeCalendar(int index) {
    setState(() {
      currentDate = index;
      if (index != 0) {
        todaybutton = 0;
      } else {
        todaybutton = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<List<SessionModel>>(context);
    print("updated data stream: " + data.toString());
    var filtereddata = data == [SessionModel.fromFirestore(null, null)]
        ? [SessionModel.fromFirestore(null, null)]
        : data
            .where((element) =>
                element.start.day ==
                    DateTime.now().add(Duration(days: currentDate)).day &&
                element.start.month ==
                    DateTime.now().add(Duration(days: currentDate)).month &&
                element.start.year ==
                    DateTime.now().add(Duration(days: currentDate)).year)
            .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 28, right: 28),
        child: Column(
          children: [
            CustomAppBar(onTodayPress, todaybutton),
            Stack(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 57,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryVariant,
                        // border: Border.all(
                        //   width: 2,
                        //   color: Color(0xffEEEEEE),
                        // ),
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ],
              ),
              Container(
                height: 57.0,
                child: CalendarList(
                    changeCalendar, currentDate, fixedExtentScrollController),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            HomeCalendar(currentDate)
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget {
  final onTodayPress;
  final todaybutton;
  CustomAppBar(this.onTodayPress, this.todaybutton);

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
                "Sessions",
                style: Theme.of(context).textTheme.headline1,
              ),
              GreenButton(
                  widget.onTodayPress, widget.todaybutton), //ontodaypress
            ],
          )
        ],
      ),
    );
  }
}

class GreenButton extends StatefulWidget {
  final onTodayPress;
  final todaybutton;

  GreenButton(this.onTodayPress, this.todaybutton);

  @override
  _GreenButtonState createState() => _GreenButtonState();
}

class _GreenButtonState extends State<GreenButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: widget.todaybutton == 1
                  ? Theme.of(context).colorScheme.primaryVariant
                  : Colors.transparent,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
              // primary: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(context).textTheme.button,
            ),
            child: Text('Today'),
            onPressed: widget.onTodayPress,
          ),
        ],
      ),
    );
  }
}

class CalendarList extends StatefulWidget {
  CalendarList(this.changeCalendar, this.currentDate, this.scrollController);
  final changeCalendar;
  final currentDate;
  final scrollController;
  @override
  _CalendarListState createState() => _CalendarListState();
}

class _CalendarListState extends State<CalendarList> {
  final List<int> days =
      List.generate(7, (index) => DateTime.now().day + index);
  static List weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> daynames = List.generate(
      7,
      (index) =>
          weekdays[DateTime.now().add(Duration(days: index)).weekday - 1]);

  // void jumpToIndex(onToday) {
  //   if (widget.scrollController.hasClients && onToday == true) {
  //     widget.scrollController.jumpTo(0.0);
  //     widget.changeCalendar = false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // jumpToIndex(widget.onToday);
    return RotatedBox(
      quarterTurns: 3,
      child: ListWheelScrollView(
        controller: widget.scrollController,
        perspective: 0.000001,
        physics: FixedExtentScrollPhysics(),
        itemExtent: 50,
        onSelectedItemChanged: widget.changeCalendar,
        children: days
            .map((day) => Container(
                  //height: 100,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          daynames[day - days[0]],
                          style: GoogleFonts.poppins(
                            color: widget.currentDate == days.indexOf(day)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onBackground,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          day.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: widget.currentDate == days.indexOf(day)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onBackground,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// class HomeCalendar extends StatefulWidget {
//   HomeCalendar(this.data);
//   final data;
//   @override
//   _HomeCalendarState createState() => _HomeCalendarState();
// }

class HomeCalendar extends StatefulWidget {
  HomeCalendar(this.currentDate);
  final currentDate;
  // final List<SessionModel> data;
  @override
  _HomeCalendarState createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  @override
  Widget build(BuildContext context) {
    var groupdets = Provider.of<List<GroupModel>>(context);
    var userdets = Provider.of<UserModel>(context);

    return StreamBuilder<List<SessionModel>>(
        stream: FirestoreService().listenToPostsRealTime(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          var sessions = data == null
              ? []
              : data
                  .where((element) =>
                      element.start.day ==
                          DateTime.now()
                              .add(Duration(days: widget.currentDate))
                              .day &&
                      element.start.month ==
                          DateTime.now()
                              .add(Duration(days: widget.currentDate))
                              .month &&
                      element.start.year ==
                          DateTime.now()
                              .add(Duration(days: widget.currentDate))
                              .year)
                  .toList();
          return Expanded(
            child: Container(
              child: sessions.length > 0
                  ? RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(Duration(milliseconds: 500));
                        FirestoreService().getSessions(special: true);
                      },
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          return CreationAwareListItem(
                            itemCreated: () {
                              if (index % 10 == 0) {
                                FirestoreService().getSessions();
                              }
                            },
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: SessionDetailPage(
                                        data: sessions[index],
                                        groupdets: groupdets,
                                        userdets: userdets),
                                    type: PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 200),
                                    reverseDuration:
                                        Duration(milliseconds: 200),
                                  ),
                                );
                              },
                              child: ListItem(sessions[index]),
                            ),
                          );
                        },
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(Duration(milliseconds: 500));
                        FirestoreService().getSessions(special: true);
                      },
                      child: ListView(children: [
                        Center(
                          child: Text(
                            'No sessions yet, create one to play!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ]),
                    ),
            ),
          );
        });
  }
}
