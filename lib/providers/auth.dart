import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/firebase_exception.dart';

class Auth with ChangeNotifier {
  String _userID;
  String _token;
  DateTime _expiryDate;
  Timer _logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return isAuth ? this._userID : null;
  }

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(String email, password, String urlSegment) async {
    final _url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAhtX9UlLDGpMEeqvkaQmqI1aAqYquzB9c";

    final response = await http.post(
      Uri.parse(_url),
      body: jsonEncode(
          {'email': email, 'password': password, 'returnSecureToken': true}),
    );
    final respondeBody = jsonDecode(response.body);
    if (respondeBody["error"] != null) {
      throw FireBaseException(respondeBody["error"]['message']);
    } else {
      this._token = respondeBody["idToken"];
      this._userID = respondeBody["localId"];
      this._expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(respondeBody["expiresIn"]),
        ),
      );

      Store.saveMap('userData', {
        "token": _token,
        "userID": _userID,
        "expiryDate": _expiryDate.toIso8601String(),
      });

      _autoLogout();
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> entrar(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) {
      return Future.value();
    }
    final userData = await Store.getMap('userData');
    if (userData == null) {
      return Future.value();
    }

    final expiryDate = DateTime.parse(userData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return Future.value();
    }

    _userID = userData["userID"];
    _token = userData["token"];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
    return Future.value();
  }

  void logout() {
    _token == null;
    _userID = null;
    _expiryDate = null;
    if (_logoutTimer != null) {
      _logoutTimer.cancel();
      _logoutTimer = null;
    }
    Store.remove('userData');
    notifyListeners();
  }

  void _autoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer.cancel();
    }
    final timeToLogout = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
