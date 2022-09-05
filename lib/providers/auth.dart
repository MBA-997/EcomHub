import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token = '';
  DateTime _expiryDate = DateTime.now();
  String _userId = '';

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDKm8SbKDMYPtQwLBMYYGMPiTyxu70jMfw');

    final response = await http.post(url,
        body: json.encode(
            {'email': email, 'password': password, 'returnSecureToken': true}));

    print(json.decode(response.body));
  }
}
