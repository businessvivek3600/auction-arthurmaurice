import 'package:action_tds/app/modules/auth/providers/user_provider.dart';
import 'package:action_tds/components/component_index.dart';
import 'package:action_tds/constants/asset_constants.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../routes/app_pages.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> sendingMail = ValueNotifier<bool>(false);
  bool haveAnOTP = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        body: ValueListenableBuilder(
            valueListenable: sendingMail,
            builder: (context, sendingEmail, child) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackButton(
                      onTap: () => Future.delayed(Duration.zero, () async {
                        primaryFocus?.unfocus();
                        await 0.5.delay();
                        return true;
                      }),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: paddingDefault),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const _AppLogo(),
                              height20(),
                              const _AppTitle(),
                              height5(),
                              const _AppSubTitle(),
                              height10(),
                              !haveAnOTP
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _AppTextField(
                                            controller: emailController,
                                            label: 'E-mail',
                                            hint: 'Enter your e-mail',
                                            icon: FontAwesomeIcons.envelope,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (value) {
                                              if (!GetUtils.isEmail(
                                                  value ?? '')) {
                                                return 'Please enter a valid e-mail';
                                              }
                                              return null;
                                            },
                                            onSubmitted: (value) =>
                                                sendVerificationMail(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        ///email
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _AppTextField(
                                                enabled: false,
                                                controller: emailController,
                                                label: 'E-mail',
                                                hint: 'Enter your e-mail',
                                                icon: FontAwesomeIcons.envelope,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                textInputAction:
                                                    TextInputAction.done,
                                                onSubmitted: (value) =>
                                                    sendVerificationMail(),
                                                validator: (value) {
                                                  if (!GetUtils.isEmail(
                                                      value ?? '')) {
                                                    return 'Please enter a valid e-mail';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        height10(),

                                        ///otp
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _AppTextField(
                                                controller: otpController,
                                                label: 'OTP',
                                                hint: 'Enter your OTP',
                                                icon: FontAwesomeIcons.handDots,
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                textInputAction:
                                                    TextInputAction.next,
                                                validator: (value) {
                                                  if (value.isEmptyOrNull ||
                                                      value!.length < 6) {
                                                    return 'Please enter a valid OTP';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        height10(),

                                        ///password
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _AppTextField(
                                                controller: passwordController,
                                                label: 'Password',
                                                hint: 'Enter your password',
                                                icon: FontAwesomeIcons.lock,
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                textInputAction:
                                                    TextInputAction.next,
                                                validator: (value) {
                                                  if (value.isEmptyOrNull ||
                                                      value!.length < 6) {
                                                    return 'Please enter a valid password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        height10(),

                                        ///confirm password
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _AppTextField(
                                                controller:
                                                    confirmPasswordController,
                                                label: 'Confirm Password',
                                                hint:
                                                    'Enter your confirm password',
                                                icon: FontAwesomeIcons.lock,
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                textInputAction:
                                                    TextInputAction.done,
                                                validator: (value) {
                                                  if (value.isEmptyOrNull ||
                                                      value!.length < 6) {
                                                    return 'Please enter a valid confirm password';
                                                  }
                                                  if (value !=
                                                      passwordController.text) {
                                                    return 'Password and confirm password does not match';
                                                  }
                                                  return null;
                                                },
                                                onSubmitted: (value) =>
                                                    _verifyOTP(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                              ///btn
                              _AppButton(
                                  label: haveAnOTP ? 'Verify OTP' : 'Send OTP',
                                  onPressed: sendingEmail
                                      ? null
                                      : haveAnOTP
                                          ? _verifyOTP
                                          : sendVerificationMail,
                                  icon: !sendingEmail
                                      ? null
                                      : const CupertinoActivityIndicator(
                                          color: Colors.white)),

                              ///resend otp
                              if (haveAnOTP)
                                TextButton.icon(
                                  label: const Text('Resend OTP'),
                                  onPressed: sendingEmail
                                      ? null
                                      : () => sendVerificationMail(true),
                                  icon: !sendingEmail
                                      ? Container()
                                      : const CupertinoActivityIndicator(
                                          color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  ///send email
  Future<void> sendVerificationMail([bool resend = false]) async {
    if (formKey.currentState!.validate()) {
      primaryFocus?.unfocus();
      sendingMail.value = true;
      if (haveAnOTP) setState(() => haveAnOTP = false);
      if (resend) {
        otpController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      }
      await (await UserProvider.instance)
          .forgotPassword(emailController.text)
          .then((value) {
        if (value) setState(() => haveAnOTP = true);
      });
      sendingMail.value = false;
    } else {
      sendingMail.value = false;
      toast('Please enter a valid email');
    }
  }

  ///verify otp
  Future<void> _verifyOTP() async {
    if (formKey.currentState!.validate()) {
      primaryFocus?.unfocus();
      sendingMail.value = true;
      await (await UserProvider.instance).forgotPasswordSubmit({
        'email': emailController.text,
        'otp': otpController.text,
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
      }).then((value) {
        if (value) {
          sendingMail.value = false;
          setState(() => haveAnOTP = false);
          emailController.clear();
          otpController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          showGeneralDialog(
              context: context,
              pageBuilder: (context, _, __) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(paddingDefault)),
                  backgroundColor: getTheme().scaffoldBackgroundColor,
                  surfaceTintColor: getTheme().scaffoldBackgroundColor,
                  title: const Text('Success'),
                  content: const Text('Password changed successfully'),
                  actions: [
                    TextButton(
                        onPressed: () => context.go(Routes.auth),
                        child: const Text('Try Login')),
                  ],
                );
              });
        }
      });
      sendingMail.value = false;
      // Get.offAllNamed(Routes.login);
    }
  }
}

class _AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  const _AppButton({
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        label: Text(label),
        icon: icon ?? const SizedBox(),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final void Function(String?)? onSubmitted;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final bool enabled;

  const _AppTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.validator,
    this.onSubmitted,
    required this.textInputAction,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 18),
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: false,
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      onFieldSubmitted: (value) {
        if (validator(value) == null) {
          primaryFocus?.unfocus();
          if (onSubmitted != null) {
            onSubmitted!(value);
          }
        }
      },
      validator: validator,
    );
  }
}

class _AppSubTitle extends StatelessWidget {
  const _AppSubTitle();

  @override
  Widget build(BuildContext context) {
    return const AutoSizeText(
      'We will send you an email with a link to reset your password',
      minFontSize: 15,
      maxFontSize: 20,
      textAlign: TextAlign.start,
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Forgot Password',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: assetImages(getAppLogo(context, true),
          height: getHeight(context) * 0.1),
    );
  }
}
