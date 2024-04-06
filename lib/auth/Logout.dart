import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../view/CustomProgress.dart';
import 'LoginScreen.dart';

/*
  Activity name : Logout API handler
  Project name : iHelpBD CRM
  Auth : Eng. Mazedul Islam
  Designation : Full Stack Software Developer
  Email : mazedulislam4970@gmail.com
*/

class Logout {
  BuildContext context;

  Logout(this.context);

  // Logout Method
  Future<void> logout() async {
    try {
      //Show logout alert
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Warning"),
          content: const Text('Do you want to logout?.',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                //Get Login status

                //Logout api call
                logoutAPI();
              },
              child: const Text('Yes'),
            )
          ],
        ),
      );
    } catch (e) {}
  }

  // Logout API Method
  void logoutAPI() async {
    CustomProgress customProgress;
    customProgress = CustomProgress(context);

    try {
      customProgress.showDialog(
          "Please wait", SimpleFontelicoProgressDialogType.spinner);

      //Show progress dialog
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      String token = sharedPreferences.getString("token").toString();
      String authorizedBy =
          sharedPreferences.getString("authorized_by").toString();
      String username = sharedPreferences.getString("username").toString();

      ///
      ///
      print("logout : ${token}");
      print("userName :${username}");
      print("authorized_byyyyy :${authorizedBy}");

      // Api url
      String url =
          'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1/logout.php';

      HttpClient httpClient = HttpClient();

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      // content type
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('token', token);
      // body

      Map<String, String> body = {
        "authorized_by": authorizedBy,
        "username": username,
      };

      request.add(utf8.encode(json.encode(body)));

      //Get response
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();

      // Closed request
      httpClient.close();

      print(reply);

      // check status code
      if (response.statusCode == 200) {
        // Parse jason data
        final data = jsonDecode(reply);
        if (data['data'] == "Logged Out Successfully") {
          //Hide progress
          customProgress.hideDialog();

          //Login status
          sharedPreferences.setBool("loginStatus", false);

          //Redirected to login page
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          //Hide progress
          customProgress.hideDialog();

          // show Error message
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Logout Error"),
              content: const Text('Invalid token',
                  style: TextStyle(color: Colors.red)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
      } else {
        //Hide progress
        customProgress.hideDialog();

        // show Error message
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout Error"),
            content: const Text('Invalid token',
                style: TextStyle(color: Colors.red)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      //Hide progress
      customProgress.hideDialog();

      // show Error message
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Logout Error"),
          content:
              const Text('Invalid token', style: TextStyle(color: Colors.red)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }
}
