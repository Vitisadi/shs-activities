
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calevent.dart';
import 'infograbber.dart';


void main() {
  runApp(const MyApp());
  createEvents();
  //infoGrabber.gatherInfo();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHS Activities',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SHS Activities'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;



  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }
  @override
  Widget build(BuildContext context) {
    // 1
    return Scaffold(
      // 2
      appBar: AppBar(
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Container(
        //     alignment: Alignment.centerLeft,
        //     child: Image.asset(
        //           'assets/staplesLogo.png',
        //           fit: BoxFit.contain,
        //           height: 32,
        //         ),
        //     ),
        //     Container(
        //         padding: const EdgeInsets.all(8.0), child: Text(widget.title)
        //     )
        //   ],
        // ),
        leading: Image.asset(
                  'assets/staplesLogo.png',
                  fit: BoxFit.contain,
                  height: 32,
                ),
        title: Text(widget.title),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              createEvents();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      // 3
      body: SafeArea(
        // 4
        child: Container(
          child: Column(
            children: <Widget>[
              // Row(
              //   children: [
              //     Expanded(
              //       flex: 1,
              //       child: Container(
              //         alignment: Alignment.topLeft,
              //         width: MediaQuery.of(context).size.width * 0.33,
              //         height: MediaQuery.of(context).size.height * 0.05,
              //         //decoration: BoxDecoration(color: Colors.greenAccent),
              //         child: const Image (
              //           image: AssetImage("assets/staplesLogo.png"),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Container(
              //         alignment: Alignment.center,
              //         width: MediaQuery.of(context).size.width * 0.33,
              //         height: MediaQuery.of(context).size.height * 0.05,
              //         //decoration: BoxDecoration(color: Colors.greenAccent),
              //         child: const Text(
              //             'SHS Activities',
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //               fontSize: 20.0,
              //               fontWeight: FontWeight.w900,
              //               color: Colors.black,
              //             ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       flex: 1,
              //       child: Container(
              //         alignment: Alignment.topRight,
              //         width: MediaQuery.of(context).size.width * 0.33,
              //         height: MediaQuery.of(context).size.height * 0.05,
              //         //decoration: BoxDecoration(color: Colors.greenAccent),
              //         child: ElevatedButton(
              //           onPressed: () {
              //
              //           },
              //           style: ElevatedButton.styleFrom(
              //               primary: Colors.transparent,
              //               ),
              //           child: const Text(
              //             '🔎',
              //             textAlign: TextAlign.right,
              //             style: TextStyle(
              //               fontSize: 30.0,
              //               fontWeight: FontWeight.w900,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              TableCalendar<Event>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  // Use `CalendarStyle` to customize the UI
                  outsideDaysVisible: false,
                ),
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          //decoration: BoxDecoration(
                            // border: Border.all(),
                            // borderRadius: BorderRadius.circular(12.0),
                            //color: Colors.red,
                          //),
                          child: Card(
                            child: ListTile(
                              leading: Image.asset(
                                'assets/img' + value[index].logo +'.png',
                                fit: BoxFit.contain,
                                height: 56,
                              ), //abc
                              onTap: () => print(value[index].logo),
                              title: Text(value[index].title),
                              subtitle: Text(value[index].startTime + ' - ' + value[index].endTime),
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outlined),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 16,
                                        child: Container(
                                          child: ListView(
                                            padding: const EdgeInsets.all(8.0),
                                            shrinkWrap: true,
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  value[index].title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].startTime + " - " + value[index].endTime),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].location),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                    text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Supervisor: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].supervisor),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Requirements: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].requirements),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Commitment: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].commitment + " hours per week"),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Description: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].description),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                padding: const EdgeInsets.all(4.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'Additional Information: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: value[index].additionalInformation),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              // trailing: PopupMenuButton(
                              //   onSelected: (value){
                              //     print(value);
                              //   },
                              //   itemBuilder: (context) => [
                              //     const PopupMenuItem(
                              //       child: Text("View Details"),
                              //       value: 1,
                              //     ),
                              //     const PopupMenuItem(
                              //       child: Text("Join Club"),
                              //       value: 2,
                              //     ),
                              //   ],
                              // ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//https://stackoverflow.com/questions/68166479/adding-events-to-table-calendar
//https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/events_example.dart
//https://pub.dev/packages/table_calendar










