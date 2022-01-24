import 'package:http/http.dart' as http;
import 'dart:convert';



class InfoGrabber{
  InfoGrabber(){}

  Future<Map<String, dynamic>> gatherInfo()  async {
    var url = Uri.parse('https://shs-clubs-and-activities.herokuapp.com/requestinfo');
    var response = await http.get(url);

    var decodeSucceeded = false;
    try {
      Map<String, dynamic> decodedJSON = json.decode(response.body);
      print("Decode Successful");
      return decodedJSON;
    } on FormatException catch (e) {
      print('Decode Failed');
      Map<String, int> emptyMap = {};
      return emptyMap;
    }
  }



}

InfoGrabber infoGrabber = InfoGrabber();