import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

import 'infograbber.dart';

import 'package:intl/intl.dart';


/// Example event class.
class Event {
  final String title, startTime, endTime, description, location, supervisor, requirements, commitment, additionalInformation, logo;

  const Event(
      this.title,
      this.startTime,
      this.endTime,
      this.description,
      this.location,
      this.supervisor,
      this.requirements,
      this.commitment,
      this.additionalInformation,
      this.logo


      );

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);//..addAll(_kEventSource);


Future<void> createEvents() async {

  Map<String, dynamic> eventsMap = await infoGrabber.gatherInfo();

  Map <DateTime, List<Event>> rawData = Map(); //T - Tuesday // R - Thursday
  for(var event in eventsMap.values) {
    if (!hasRequiredValues(event)) continue;
    var days = event["day"].split(", ");
    for (var daySelected = 0; daySelected < days.length; daySelected++) {
      DateTime nextClubDay = DateTime.now().next(int.parse(days[daySelected])); //loop through week day
      DateTime clubDate = new DateTime(nextClubDay.year, nextClubDay.month, nextClubDay.day, 0, 0, 0);

      int day = int.parse(days[daySelected]);
      var endDate = new DateTime(clubDate.year, clubDate.month + 3, clubDate.day);
      while (endDate.isAfter(clubDate)) {
        var existingClub = rawData[clubDate];
        var newEvent = Event(
            event["name"],
            event["start_time"],
            event["end_time"],
            event["description"],
            event["location"],
            event["supervisor"],
            event["requirements"],
            event["commitment"],
            event["additional_info"],
            event["logo"]
        );

        if (rawData.containsKey(clubDate)) {
          var oldData = rawData[clubDate];
          oldData!.add(newEvent);
          rawData.remove(clubDate);
          rawData[clubDate] = oldData;
        } else {
          rawData[clubDate] = [newEvent];
        }


        clubDate = getNewDate(clubDate, event["frequency"]);

        //   clubDate = getNewDate(clubDate, event["frequency"]);
        //       //clubDate.add(const Duration(days: 7));
      }
  }
    //print(event);
  }
  //print(rawData.keys);

  //print(rawData);

  // this.title,
  // this.startTime,
  // this.endTime,
  // this.description,
  // this.location,
  // this.supervisor,
  // this.requirements,
  // this.commitment,
  // this.additionalInformation





  //rawData[DateTime.utc(2021, 12, 13)] = [Event("Another Club", "11:00 am", "3:00 pm", "This is another club", "Room 190", "Nobody","asfsf@gmail.com", "Have fun", "2", "Nothing")];
  // rawData[DateTime.utc(2021, 12, 11)] = [Event("Spend lots of time deciphering bad documentation.")];
  // rawData[DateTime.utc(2021, 12, 13)] = [Event("Go to dinner at a nice restaurant cause we figured this out.")];
  kEvents.addAll(rawData);
  //print(kEvents);
}

DateTime getNewDate(DateTime date, String frequency){
  DateTime newDate = DateTime.now();
  switch(frequency){
    case "weekly":
      newDate = date.add(const Duration(days: 7));
      break;
    case "biweekly":
      newDate = date.add(const Duration(days: 14));
      break;
    case "monthly":
      newDate = new DateTime(date.year, date.month + 3, date.day);
      break;
    default:
      newDate = date.add(const Duration(days: 7));
  }
  return newDate;
}

extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    return this.add(
      Duration(
        days: (day - this.weekday) % DateTime.daysPerWeek,
      ),
    );
  }
}


bool hasRequiredValues(var event){
  if(event["name"] == null) {
    print("Error: unnamed event");
    return false;
  }

  //add contact to json
  final List<String> checkValues = ["start_date", "start_time", "end_time", "description", "location", "supervisor", "requirements", "commitment", "additional_info"];
  for(var checkValue in checkValues){
    if(event[checkValue] == null) {
      print("Error: " + event["name"] + " did not have a " + checkValue);
      return false;
    }
  }
  return true;
}


// kEvents.addEntries(DateTime.utc(kFirstDay.year, kFirstDay.month, 5), newEntries)
// final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
//     key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
//     value: (item) => List.generate(
//         item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
//   ..addAll({
//     kToday: [
//       Event('Today\'s Event 1'),
//       Event('Today\'s Event 2'),
//     ],
//   });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);