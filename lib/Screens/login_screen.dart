// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newchatapp/Functions/Auth/auth_functions.dart';
import 'package:newchatapp/Screens/SignUp.dart';
import 'package:newchatapp/Screens/home_screen.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:newchatapp/Widgets/snackbar.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailc = TextEditingController();
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
  String Perror = '';
  // final AuthFunctions authMethods = AuthFunctions();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return isloading
        ? Scaffold(
            body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Loging..',
                    style: GoogleFonts.fredokaOne(
                      fontSize: 20,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ))
        : Scaffold(
            // backgroundColor: Colors.white,
            body: SafeArea(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 6,
                  ),
                  Center(
                    child: Text(
                      'Login',
                      style: GoogleFonts.fredokaOne(
                          fontSize: 70, color: kPrimaryColor),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  // SvgPicture.asset('images/login.svg', height: size.height * 0.3),
                  // SizedBox(
                  //   height: size.height * 0.03,
                  // ),
                  Center(
                    child: TextFieldContainer(
                        color: error.isNotEmpty ? Colors.red : kPrimaryColor,
                        child: TextField(
                          onSubmitted: (v) async {
                            String result = await AuthFunction().loginUser(
                                emailc.text, passwordc.text, context);

                            if (result == 'error-user') {
                              setState(() {
                                error = 'Email Not Found!';
                                Perror = '';
                              });
                            } else if (result == 'error-pass') {
                              setState(() {
                                Perror = 'Wrong Password!';
                                error = '';
                              });
                            } else if (result == 'fields-error') {
                              error = "Email is Empty";
                              Perror = "Password is Empty";
                              setState(() {});
                            }
                            if (result == 'invalid-email') {
                              setState(() {
                                error = '';
                                Perror = '';
                                error = "Your Email Is Badly Formatted!";
                              });
                            }
                            if (result == '') {
                              setState(() {
                                isloading = true;
                              });
                              await Future.delayed(Duration(milliseconds: 3000))
                                  .then((value) => Get.to(homeScreen()));
                            }
                          },
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
                  ),
                  error.isEmpty
                      ? Container()
                      : Text(error,
                          style: TextStyle(
                            color: Colors.red,
                          )),
                  Center(
                    child: TextFieldContainer(
                        color: Perror.isNotEmpty ? Colors.red : kPrimaryColor,
                        child: TextField(
                          onSubmitted: (value) async {
                            String result = await AuthFunction().loginUser(
                                emailc.text, passwordc.text, context);

                            if (result == 'error-user') {
                              setState(() {
                                error = 'Email Not Found!';
                                Perror = '';
                              });
                            } else if (result == 'error-pass') {
                              setState(() {
                                Perror = 'Wrong Password!';
                                error = '';
                              });
                            } else if (result == 'fields-error') {
                              error = "Email is Empty";
                              Perror = "Password is Empty";
                              setState(() {});
                            }
                            if (result == 'invalid-email') {
                              setState(() {
                                error = '';
                                Perror = '';
                                error = "Your Email Is Badly Formatted!";
                              });
                            }
                            if (result == '') {
                              setState(() {
                                isloading = true;
                              });
                              await Future.delayed(Duration(milliseconds: 3000))
                                  .then((value) => Get.to(homeScreen()));
                            }
                          },
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
                  ),
                  Perror.isEmpty
                      ? Container()
                      : Text(Perror,
                          style: TextStyle(
                            color: Colors.red,
                          )),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Center(
                      child: customButton(
                          text: 'Login',
                          onPressed: () async {
                            String result = await AuthFunction().loginUser(
                                emailc.text, passwordc.text, context);

                            if (result == 'error-user') {
                              setState(() {
                                error = 'Email Not Found!';
                                Perror = '';
                              });
                            } else if (result == 'error-pass') {
                              setState(() {
                                Perror = 'Wrong Password!';
                                error = '';
                              });
                            } else if (result == 'fields-error') {
                              error = "Email is Empty";
                              Perror = "Password is Empty";
                              setState(() {});
                            }
                            if (result == 'invalid-email') {
                              setState(() {
                                error = '';
                                Perror = '';
                                error = "Your Email Is Badly Formatted!";
                              });
                            }
                            if (result == '') {
                              setState(() {
                                isloading = true;
                              });
                              await Future.delayed(Duration(milliseconds: 3000))
                                  .then((value) => Get.to(homeScreen()));
                            }
                          })),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t Have an Account?',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return SignUp();
                              }));
                            },
                            child: Text(
                              'SignUp',
                              style:
                                  TextStyle(fontSize: 20, color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
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
