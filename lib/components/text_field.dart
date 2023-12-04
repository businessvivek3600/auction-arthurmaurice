import 'package:flutter/material.dart';

class CustomPasswordTextField extends StatefulWidget {
  const CustomPasswordTextField(
      {super.key, required this.builder, this.onPasswordVisible});
  final Widget Function(bool visible, Function tooglePasswordVisibility)
      builder;

  /// Callback to be called when the password visibility is changed
  final Function(bool)? onPasswordVisible;

  @override
  State<CustomPasswordTextField> createState() =>
      _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool _passwordVisible = false;

  tooglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
    if (widget.onPasswordVisible != null) {
      widget.onPasswordVisible!(_passwordVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_passwordVisible, tooglePasswordVisibility);
  }
}
