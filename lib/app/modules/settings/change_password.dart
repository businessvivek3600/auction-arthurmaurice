import 'dart:io';

import 'package:action_tds/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/component_index.dart';
import '../auth/providers/user_provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  ValueNotifier<bool> _runningUpdate = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Change Password',
          minFontSize: (getTheme(context).textTheme.titleLarge?.fontSize ?? 17),
          maxFontSize: 30,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsetsDirectional.all(paddingDefault),
          children: [
            /// textfields for  three password fields with hidden password and text inputaction next, also add prefix to each
            CustomPasswordTextField(
              onPasswordVisible: (value) {},
              builder: ((visible, tooglePasswordVisibility) {
                return TextFormField(
                  controller: _passwordController,
                  obscureText: !visible,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: false,
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () => tooglePasswordVisibility(),
                        icon: Icon(
                            visible ? Icons.visibility : Icons.visibility_off)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                );
              }),
            ),

            ///new password
            height10(),
            CustomPasswordTextField(
              onPasswordVisible: (value) {},
              builder: ((visible, tooglePasswordVisibility) {
                return TextFormField(
                  controller: _newPasswordController,
                  obscureText: !visible,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    filled: false,
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () => tooglePasswordVisibility(),
                        icon: Icon(
                            visible ? Icons.visibility : Icons.visibility_off)),
                  ),
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                );
              }),
            ),

            ///confirm password
            height10(),
            CustomPasswordTextField(
              onPasswordVisible: (value) {},
              builder: ((visible, tooglePasswordVisibility) {
                return TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !visible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    filled: false,
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () => tooglePasswordVisibility(),
                        icon: Icon(
                            visible ? Icons.visibility : Icons.visibility_off)),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (val) => _update(),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Password does not match';
                    }
                    return null;
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: _runningUpdate,
          builder: (context, val, _) {
            return Container(
              padding: EdgeInsetsDirectional.only(
                  start: paddingDefault,
                  end: paddingDefault,
                  bottom:
                      paddingDefault + (Platform.isIOS ? paddingDefault : 0)),
              child: ElevatedButton.icon(
                onPressed: _update,
                icon: AutoSizeText(
                  'Update',
                  minFontSize:
                      (getTheme(context).textTheme.bodyLarge?.fontSize ?? 17),
                  maxFontSize: 30,
                ),
                label: val
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const SizedBox(height: 0, width: 0),
              ),
            );
          }),
    );
  }

  void _update() async {
    if (_formKey.currentState!.validate()) {
      _runningUpdate.value = true;
      (await UserProvider.instance).updatePassword(context, {
        'current_password': _passwordController.text,
        'password': _newPasswordController.text,
        'password_confirmation': _confirmPasswordController.text,
      }).then((value) => value ? Navigator.pop(context) : null);
      _runningUpdate.value = false;
    }
  }
}
