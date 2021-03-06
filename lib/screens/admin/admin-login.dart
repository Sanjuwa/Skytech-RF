import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:skytech/screens/admin/admin-dashboard.dart';
import 'package:skytech/screens/admin/admin-register.dart';
import 'package:skytech/widgets/button.dart';
import 'package:skytech/widgets/custom-text.dart';
import 'package:skytech/widgets/inputfield.dart';
import 'package:skytech/widgets/toast.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  logIn() async {
    await Firebase.initializeApp();
    ToastBar(color: Colors.orange,text: 'Please wait...').show();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text,
          password: password.text
      );

      var sub = await FirebaseFirestore.instance.collection('admin').where('email',isEqualTo: email.text).get();
      var logged = sub.docs;

      if(logged.isNotEmpty){
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => AdminDashboard(name: logged[0]['name'],code: logged[0]['code'],)),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        ToastBar(color: Colors.red,text: 'User not found!').show();
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        ToastBar(color: Colors.red,text: 'Password wrong!').show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(720, 1520), allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                CustomText(text: 'Log In',size: ScreenUtil().setSp(60)),

                InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                InputField(hint: 'Password',ispassword: true,controller: password,),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                  child: Button(text: 'Login',onclick: ()=>logIn(),),
                ),

                GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => AdminRegister()),
                      );
                    },
                    child: CustomText(text: "Don't have an account? Sign up",size: ScreenUtil().setSp(30),)),



              ],
            ),
          ),
        ),
      ),
    );
  }
}
