import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:misattendance/screens/homepage.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:http/http.dart' as http;
import 'package:misattendance/service/toast.dart';

class SigninPanel extends StatefulWidget {
  const SigninPanel({Key key}) : super(key: key);

  @override
  _SigninPanelState createState() => _SigninPanelState();
}

class _SigninPanelState extends State<SigninPanel> {
  bool loginstarted;
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();
  Toast ts = new Toast();
  var data;
  @override
  void initState() {
    super.initState();
    loginstarted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 150),

            Center(
              child: Image.asset(
                'assets/emp.png',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: Text(
                'Sign in',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                'Stay tuned with employee attendance',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 10,
              ),
              child: TextFormField(
                keyboardType: TextInputType.text,
                autofocus: false,
                controller: user,
                style: new TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  hintText: 'Employee ID',
                  contentPadding: EdgeInsets.fromLTRB(30.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(
                    Icons.verified_user_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 10,
              ),
              child: TextFormField(
                keyboardType: TextInputType.text,
                autofocus: false,
                controller: pass,
                obscureText: true,
                style: new TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: EdgeInsets.fromLTRB(30.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ),
            ),
            // ignore:

            SizedBox(
              height: 10,
            ),

            loginstarted == false
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        if (user.text.length > 1 && pass.text.length > 1) {
                          employeeLogin();
                          setState(() {
                            loginstarted = true;
                          });
                        } else {
                          ts.showfluttertoast('All fields are required');
                        }
                      },
                      splashColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(
                              50.0,
                            ))),
                        child: ListTile(
                          minVerticalPadding: 0,
                          title: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          trailing: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.login_sharp,
                                size: 25,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: SpinKitRipple(
                      color: Colors.blue,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future employeeLogin() async {
    var response = await http.get(Uri.parse(
        "http://api.mnds.tech/login.php?email=${user.text}&password=${pass.text}&action=authenticate&tb=employee"));

    data = json.decode(response.body);
    print(data);
    if (data['status'] == 201) {
      ts.showfluttertoast('Invalid Email or Password.');
      setState(() {
        loginstarted = false;
      });
    }

    if (data['status'] == 200) {
      ts.showfluttertoast('Welcome! you have login.');
      setState(() {
        loginstarted = false;
      });
      EasyDebounce.debounce(
          'my-debouncer', // <-- An ID for this particular debouncer
          Duration(milliseconds: 1000), // <-- The debounce duration
          () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePage(data: data))));
    }
  }
}
