import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime? _expiryDate = null;
  String _userId = '';
  Timer? _authTimer = null;

  bool get isAuth {
    return _token != '';
  }

  String get token {
    if (_token != '' &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }

    return '';
  }

  String get useId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDKm8SbKDMYPtQwLBMYYGMPiTyxu70jMfw');

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      // print(json.decode(response.body));
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
          {'token': _token, 'userId': _userId, 'expiryDate': _expiryDate});

      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final userExtractedData = json
        .decode(prefs.getString('userData').toString()) as Map<String, dynamic>;

    final userExpiryDate = DateTime.parse(userExtractedData['expiryDate']);

    if (userExpiryDate.isBefore(DateTime.now())) return false;

    _token = userExtractedData['token'];
    _userId = userExtractedData['userId'];
    _expiryDate = userExpiryDate;
    notifyListeners();
    _autoLogout();

    return true;
  }

  void logout() async {
    _userId = '';
    _expiryDate = DateTime.now();
    _token = '';
    _authTimer?.cancel();

    _authTimer = null;
    notifyListeners();

    //Cleans all the login info in device storage
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }

    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
