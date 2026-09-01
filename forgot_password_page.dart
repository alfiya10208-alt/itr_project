import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;

  // RESET PASSWORD
  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30,
                ),

                SizedBox(width: 10),

                Text(
                  "Email Sent",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            content: const Text(
              "A password reset link has been sent "
                  "to your email address.",
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },

                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // FIREBASE ERRORS
    on FirebaseAuthException catch (e) {
      String message = "Something went wrong.";

      if (e.code == 'user-not-found') {
        message = "No account found with this email.";
      }

      else if (e.code == 'invalid-email') {
        message = "Please enter a valid email address.";
      }

      else if (e.code == 'network-request-failed') {
        message = "Please check your internet connection.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // OTHER ERRORS
    catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // DISPOSE
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // BACKGROUND IMAGE
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/reg_bg.webp",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Container(
          // DARK OVERLAY
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.35),
          ),

          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),

                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(25),

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(.25),

                          blurRadius: 25,

                          offset:
                          const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Form(
                      key: formKey,

                      child: Column(
                        children: [
                          // LOCK ICON
                          Container(
                            padding:
                            const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(.08),

                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.lock_reset,
                              size: 55,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // TITLE
                          const Text(
                            "Forgot Password?",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              fontSize: 28,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // DESCRIPTION
                          Text(
                            "Don't worry! Enter your registered "
                                "email address and we'll send you "
                                "a link to reset your password.",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              fontSize: 15,
                              color:
                              Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // EMAIL FIELD
                          TextFormField(
                            controller:
                            emailController,

                            keyboardType:
                            TextInputType.emailAddress,

                            decoration:
                            InputDecoration(
                              labelText:
                              "Email Address",

                              hintText:
                              "Enter your email",

                              prefixIcon:
                              const Icon(
                                Icons.email_outlined,
                              ),

                              filled: true,

                              fillColor:
                              Colors.grey.shade100,

                              contentPadding:
                              const EdgeInsets
                                  .symmetric(
                                vertical: 17,
                              ),

                              border:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(15),

                                borderSide:
                                BorderSide.none,
                              ),

                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(15),

                                borderSide:
                                const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return "Please enter your email";
                              }

                              if (!value.contains('@')) {
                                return "Enter a valid email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          // RESET BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,

                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : resetPassword,

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.black,

                                foregroundColor:
                                Colors.white,

                                elevation: 4,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(15),
                                ),
                              ),

                              child: loading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,

                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )

                                  : const Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                                children: [

                                  Icon(
                                    Icons
                                        .send_outlined,
                                    size: 20,
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    "Send Reset Link",

                                    style:
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // BACK TO LOGIN
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            icon: const Icon(
                              Icons.arrow_back,
                              size: 18,
                            ),

                            label: const Text(
                              "Back to Login",
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // SECURITY TEXT
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.security,
                                size: 15,
                                color:
                                Colors.grey.shade500,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                "Your account is secure",
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                  Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}