import 'package:shared_preferences/shared_preferences.dart';

logoutUser()async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool("isLogin",false);
  pref.setString("userRole","");
  pref.setString("email","");
  pref.setString("password","");
}