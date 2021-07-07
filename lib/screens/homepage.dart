import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:misattendance/service/toast.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final data;
  const HomePage({Key key, @required this.data}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Geolocator geolocator = Geolocator();
  Position userLocation;
  var lat;
  var lng;
  var inout;

  var apikey = "48fe5be7a151cff4bda3415efc3c778e";
  var tag;
  var time;
  var address;
  var date = DateTime.now();

  Toast ts = new Toast();

  var css = TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  );

  var color = Colors.blueGrey;

  @override
  void initState() {
    super.initState();
    tag = "In";
    _requestGpsPermission();
    _getAttendance();
  }

  _requestGpsPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.location.request();
      ts.showfluttertoast('Enable GPS');
    } else {
      ts.showfluttertoast("Location Enabled.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 150,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Text(
                'Employee Attendance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: CircleAvatar(
                radius: 30,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    widget.data['data'][0]['icon'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Text(
                tag + ' Time: ' + time,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: new LinearGradient(
          colors: [
            Colors.blue,
            Colors.white,
            Colors.white,
          ],
          stops: [0.4, 0.3, 0.2],
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomRight,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                children: [
                  // ignore: deprecated_member_use
                  Expanded(
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      disabledColor: Colors.blue[300],
                      splashColor: Colors.yellow,
                      onPressed: () {
                        _invokeLocation();

                        setState(() {
                          inout = "in";
                        });
                      },
                      child: Text(
                        'Check In',
                        style: css,
                      ),
                      color: Colors.orange[500],
                    ),
                  ),

                  VerticalDivider(
                    color: Colors.white,
                    width: 5.0,
                  ),
                  Expanded(
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      splashColor: Colors.yellow,
                      disabledColor: Colors.blue[300],
                      onPressed: () {
                        _invokeLocation();

                        setState(() {
                          inout = "out";
                        });
                      },
                      child: Text(
                        'Check Out',
                        style: css,
                      ),
                      color: Colors.orange[500],
                    ),
                  ),
// ignore: deprecated_member_use
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                tileColor: color,
                leading: Text(
                  'Emp Id:',
                  style: css,
                ),
                trailing: Text(
                  widget.data['data'][0]['id'],
                  style: css,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                tileColor: color,
                leading: Text(
                  'Employee Name:',
                  style: css,
                ),
                trailing: Text(
                  widget.data['data'][0]['name'],
                  style: css,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                tileColor: color,
                leading: Text(
                  'Role:',
                  style: css,
                ),
                trailing: Text(
                  widget.data['data'][0]['role'],
                  style: css,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                tileColor: color,
                leading: Text(
                  'Superior Name:',
                  style: css,
                ),
                trailing: Text(
                  widget.data['data'][0]['sup_name'],
                  style: css,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                tileColor: color,
                leading: Text(
                  'Branch:',
                  style: css,
                ),
                trailing: Text(
                  widget.data['data'][0]['branch'],
                  style: css,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                tileColor: color,
                leading: Text(
                  'Account Created:',
                  style: css,
                ),
                trailing: Text(
                  widget.data['data'][0]['created_date'],
                  style: css,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showalert(var msg, var typ) {
    return CoolAlert.show(
      context: context,
      type: typ,
      text: msg,
    );
  }

  getAddress(var lat, var lng) async {
    var response = await http.get(Uri.parse(
        "http://api.positionstack.com/v1/reverse?access_key=${apikey}&query=${lat},${lng}"));
    var res = json.decode(response.body);
    var k = res['data'][0]['label'];
    ts.showfluttertoast(k);

    setState(() {
      address = k;
    });

    _saveAttendance(inout);
  }

  _invokeLocation() {
    _getLocation().then((position) {
      userLocation = position;
      setState(() {
        lat = userLocation.latitude;
        lng = userLocation.longitude;
      });
      getAddress(lat, lng);
    });
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  _getAttendance() async {
    var response = await http.get(Uri.parse(
        "http://api.mnds.tech/attendance.php?empid=${widget.data['data'][0]['id']}&action=getattendance&tb=attendance"));
    var res = json.decode(response.body);
    setState(() {
      time = res;
    });
  }

  _saveAttendance(var inout) async {
    var response = await http.get(Uri.parse(
        "http://api.mnds.tech/attendance.php?empid=${widget.data['data'][0]['id']}&action=${inout}&tb=attendance&address=${address}"));
    var res = json.decode(response.body);

    print(res);
    if (response.statusCode == 200) {
      _showalert(res + ", Address: " + address, CoolAlertType.info);
      _getAttendance();
    } else {
      _showalert("Error ocurred while processing request", CoolAlertType.info);
    }
  }
}
