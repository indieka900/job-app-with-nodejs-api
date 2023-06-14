import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nodejs_app/constants/app_constants.dart';
import 'package:flutter_nodejs_app/controllers/exports.dart';
import 'package:flutter_nodejs_app/views/common/app_bar.dart';
import 'package:flutter_nodejs_app/views/common/app_style.dart';
import 'package:flutter_nodejs_app/views/common/custom_btn.dart';
import 'package:flutter_nodejs_app/views/common/custom_textfield.dart';
import 'package:flutter_nodejs_app/views/common/height_spacer.dart';
import 'package:flutter_nodejs_app/views/common/reusable_text.dart';
import 'package:flutter_nodejs_app/views/ui/auth/signup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/request/auth/login_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(
      builder: (context, value, child) {
        value.getPrefs();
        bool loading = value.loading;
        Future.delayed(const Duration(seconds: 5)).then((value) {
          if (loading) {
            setState(() async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool('loading', false);
            });
          }
        });
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: CustomAppBar(
              text: "Login ",
              child: !value.entryPoint && value.isLoggedIn
                  ? GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(CupertinoIcons.arrow_left),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: value.loginFormKey,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      const HeightSpacer(size: 50),
                      ReusableText(
                        text: 'Welcome Back',
                        style: appstyle(
                          30,
                          Color(kDark.value),
                          FontWeight.w600,
                        ),
                      ),
                      ReusableText(
                        text: 'Fill in the details to login to your account',
                        style: appstyle(
                          16,
                          Color(kDarkGrey.value),
                          FontWeight.w600,
                        ),
                      ),
                      const HeightSpacer(size: 50),
                      CustomTextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        hintText: "Email",
                        validator: (email) {
                          if (email!.isEmpty) {
                            return "Please enter a valid email";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const HeightSpacer(size: 20),
                      CustomTextField(
                        controller: password,
                        obscureText: value.obscureText,
                        keyboardType: TextInputType.text,
                        hintText: "Password",
                        validator: (password) {
                          if (password!.isEmpty || password.length < 8) {
                            return "Please enter a valid password";
                          } else {
                            return null;
                          }
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            value.obscureText = !value.obscureText;
                          },
                          child: Icon(
                            value.obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color(kDark.value),
                          ),
                        ),
                      ),
                      const HeightSpacer(size: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const RegistrationPage());
                          },
                          child: ReusableText(
                            text: "Register",
                            style: appstyle(
                                14, Color(kDark.value), FontWeight.w500),
                          ),
                        ),
                      ),
                      const HeightSpacer(size: 50),
                      CustomButton(
                        onTap: () {
                          if (value.validateAndSave()) {
                            LoginModel model = LoginModel(
                              username: email.text,
                              password: password.text,
                            );

                            value.userLogin(model);
                          } else {
                            Get.snackbar(
                              'Sign failing',
                              'Please check your credentials and internet',
                              colorText: Color(kLight.value),
                              backgroundColor: Colors.red,
                              icon: const Icon(Icons.add_alert),
                            );
                          }
                        },
                        text: "Login",
                      )
                    ],
                  ),
                ),
              ),
              loading
                  ? Container(
                      color: Colors.white.withOpacity(0.5),
                      height: hieght,
                      width: width,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(kOrange.value),
                          strokeWidth: 6,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
