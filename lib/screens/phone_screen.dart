import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_firebase_auth/services/firebase_auth_methods.dart';
import 'package:my_flutter_firebase_auth/utils/showOtpDialog.dart';
import 'package:my_flutter_firebase_auth/utils/showSnackbar.dart';
import 'package:my_flutter_firebase_auth/widgets/custom_button.dart';
import 'package:my_flutter_firebase_auth/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneScreen extends StatefulWidget {
  static String routeName = '/phone';
  const PhoneScreen({Key? key}) : super(key: key);

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextField(
            controller: phoneController,
            hintText: 'Enter phone number',
          ),
          CustomButton(
            onTap: () async {
              final navigator = Navigator.of(context);

              await context.read<FirebaseAuthMethods>().phoneSignIn(
                    phoneNumber: phoneController.text,
                    onCodeSent: (verfiationId, resendToken) async {
                      final codeController = TextEditingController();

                      showOTPDialog(
                        context: context,
                        codeController: codeController,
                        onPressed: () async {
                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                            verificationId: verfiationId,
                            smsCode: codeController.text.trim(),
                          );
                          try {
                            await context
                                .read<FirebaseAuthMethods>()
                                .signInWithCredential(credential);
                            navigator.popUntil((route) => route.isFirst);
                          } on FirebaseAuthException catch (e) {
                            showSnackBar(context, e.message!);
                          }
                        },
                      );
                    },
                    onFailed: (e) {
                      showSnackBar(context, e.message!);
                    },
                  );
            },
            text: 'OK',
          ),
        ],
      ),
    );
  }
}
