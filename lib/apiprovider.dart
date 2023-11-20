import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class api_Pro {
  api_Pro();
  String localapi = "https://tame-jade-duckling-cape.cyclic.app/";
  // String localapi = "http://localhost:3000";
  Future<http.Response> doChecklogin(String id, String email) async {
    // print("object");
    var _url = Uri.parse('$localapi/checkstd');
    var json = jsonEncode(<String, String>{"id": id, "email": email});
    print(_url);
    return await http.post(_url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: json);
  }
  Future<http.Response> doCheckname(String idmobile, String location_lati,String location_longti) async {
    // print("object");
    var _url = Uri.parse('$localapi/checkstd');
    var json = jsonEncode(<String, String>{"idmobile": idmobile, "location_lati": location_lati, "location_longti": location_longti});
    print(_url);
    return await http.post(_url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: json);
  }
  Future<http.Response> dochecktime(String timenow,String id, String location_lati,String location_longti,String emiphone) async {
    // print("object");
    var _url = Uri.parse('$localapi/checktime_now');
    var json = jsonEncode(<String, String>{"timenow": timenow,"id" : id, "lati": location_lati, "longti": location_longti,"emi":emiphone});
    print(_url);
    return await http.post(_url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: json);
  }
   Future<http.Response> dohistoryscore(String id,String sub_id) async {
    // print("object");
    var _url = Uri.parse('$localapi/historyscore');
    var json = jsonEncode(<String, String>{"id" : id,"sub_id":sub_id});
    print(_url);
    return await http.post(_url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: json);
  }
  Future<http.Response> dodatasubject(String id) async {
    // print("object");
    var _url = Uri.parse('$localapi/datasubject');
    var json = jsonEncode(<String, String>{"id" : id});
    print(_url);
    return await http.post(_url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: json);
  }
  Future<http.Response> dodataannounce(String id,String sub_id) async {
    // print("object");
    var _url = Uri.parse('$localapi/dataannoune');
    var json = jsonEncode(<String, String>{"id" : id,"sub_id":sub_id});
    print(_url);
    return await http.post(_url,
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
        },
        body: json);
  }

  // dataannoune
}
