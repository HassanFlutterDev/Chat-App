// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newchatapp/Functions/Auth/auth_functions.dart';
import 'package:newchatapp/Screens/home_screen.dart';
import 'package:newchatapp/Screens/loading_screen.dart';
import 'package:newchatapp/Screens/login_screen.dart';
import 'package:newchatapp/Theme/theme.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailc = TextEditingController();
  TextEditingController userc = TextEditingController();
  TextEditingController passwordc = TextEditingController();
  bool obsecure = true;
  bool isloading = false;

  // Future login() async {
  //   setState(() {
  //     isloading = true;
  //   });
  //   AuthFunctions.instance.loginUser(emailc.text, passwordc.text);
  // }

  @override
  void dispose() {
    emailc.dispose();
    passwordc.dispose();

    super.dispose();
  }

  void _togglepassword() {
    if (obsecure == true) {
      setState(() {
        obsecure = false;
      });
    } else {
      setState(() {
        obsecure = true;
      });
    }
  }

  String error = '';
  String Eerror = '';
  String Perror = '';
  // final AuthFunctions authMethods = AuthFunctions();
  @override
  Widget build(BuildContext context) {
    bool loading1 = false;

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 7,
            ),
            Text(
              'Sign Up',
              style: GoogleFonts.fredokaOne(fontSize: 60, color: kPrimaryColor),
            ),

            SizedBox(
              height: size.height * 0.02,
            ),
            // SvgPicture.asset('images/login.svg', height: size.height * 0.3),
            // SizedBox(
            //   height: size.height * 0.03,
            // ),
            TextFieldContainer(
                color: error.isNotEmpty ? Colors.red : kPrimaryColor,
                child: TextField(
                  controller: userc,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Username',
                    icon: Icon(
                      CupertinoIcons.person_fill,
                      color: kPrimaryColor,
                    ),
                  ),
                )),
            error.isEmpty
                ? Container()
                : Text(error,
                    style: TextStyle(
                      color: Colors.red,
                    )),
            TextFieldContainer(
                color: Eerror.isNotEmpty ? Colors.red : kPrimaryColor,
                child: TextField(
                  controller: emailc,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email',
                    icon: Icon(
                      Icons.alternate_email_outlined,
                      color: kPrimaryColor,
                    ),
                  ),
                )),
            Eerror.isEmpty
                ? Container()
                : Text(Eerror,
                    style: TextStyle(
                      color: Colors.red,
                    )),
            TextFieldContainer(
                color: Perror.isNotEmpty ? Colors.red : kPrimaryColor,
                child: TextField(
                  controller: passwordc,
                  obscureText: obsecure,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                      icon: Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: GestureDetector(
                          onTap: _togglepassword,
                          child: obsecure
                              ? Icon(
                                  Icons.visibility,
                                  color: kPrimaryColor,
                                )
                              : Icon(
                                  Icons.visibility_off,
                                  color: kPrimaryColor,
                                ))),
                )),
            Perror.isEmpty
                ? Container()
                : Text(Perror,
                    style: TextStyle(
                      color: Colors.red,
                    )),
            // SizedBox(
            //   height: 10,
            // ),
            isloading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  )
                : customButton(
                    text: 'SignUp',
                    onPressed: () async {
                      log('email ${emailc.text}');
                      setState(() {
                        isloading = true;
                      });
                      if (userc.text.length <= 5) {
                        setState(() {
                          isloading = false;
                          error = 'Username Should be at least 6 Characters!';
                        });
                      } else {
                        String result = await AuthFunction().Signup(
                            emailc.text,
                            passwordc.text,
                            userc.text,
                            // _image!
                            context);

                        if (result == 'password-error') {
                          setState(() {
                            isloading = false;
                            error = '';
                            Eerror = '';
                            Perror =
                                "Password Should be at least 6 Characters!";
                          });
                        }
                        if (result == 'email-error') {
                          setState(() {
                            isloading = false;
                            error = '';
                            Perror = '';
                            Eerror =
                                "Email is Already in Used By Another Account!";
                          });
                        }
                        if (result == 'fields-error') {
                          setState(() {
                            isloading = false;
                            // error = "Username is Empty";
                            Eerror = "Email is Empty";
                            Perror = "Password is Empty";
                          });
                        }
                        if (result == 'invalid-email') {
                          setState(() {
                            isloading = false;
                            error = '';
                            Perror = '';
                            Eerror = "Your Email Is Badly Formatted!";
                          });
                        }
                        if (userc.text.length <= 5) {
                          setState(() {
                            isloading = false;
                            error = 'Username Should be 6 Characters!';
                          });
                        }
                        if (result == '' && userc.text.length >= 5) {
                          setState(() {
                            isloading = true;
                          });
                          Get.to(homeScreen());
                        }
                      }
                    }),
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         height: 3,
            //         width: 80,
            //         color: Colors.grey,
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 3),
            //         child: Text(
            //           'or',
            //           style: TextStyle(color: kPrimaryColor, fontSize: 17),
            //         ),
            //       ),
            //       Container(
            //         height: 3,
            //         width: 80,
            //         color: Colors.grey,
            //       )
            //     ],
            //   ),
            // ),
            // customButton(text: 'Login With Google', onPressed: () async {}),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have an Account?',
                    style: TextStyle(fontSize: 20),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return Login();
                      }));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 20, color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  Color color;
  TextFieldContainer({Key? key, required this.child, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.9,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

// class background extends StatelessWidget {
//   const background({Key? key, required this.child}) : super(key: key);

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Container(
//       height: size.height,
//       width: double.infinity,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//               left: 0,
//               top: 0,
//               child: Image.asset(
//                 'images/main_top.png',
//                 height: size.width * 0.4,
//               )),
//           Positioned(
//               bottom: 0,
//               left: 0,
//               child: Image.asset(
//                 'images/main_bottom.png',
//                 colorBlendMode: BlendMode.darken,
//                 height: size.width * 0.3,
//               )),
//           Positioned(
//               bottom: 0,
//               right: 0,
//               child: Image.asset(
//                 'images/login_bottom.png',
//                 colorBlendMode: BlendMode.darken,
//                 height: size.width * 0.3,
//               )),
//           child,
//         ],
//       ),
//     );
//   }
// }

class customButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const customButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: CupertinoButton(
        onPressed: onPressed,
        child: Container(
          width: double.infinity,
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
        minSize: kMinInteractiveDimensionCupertino,
        borderRadius: BorderRadius.circular(5),
        color: kPrimaryColor,
      ),
    );
  }
}
