import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/styles.dart';


class InputFields {
  static InputBorder get border => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.lightBlueAccent)
  );
  static void unFocus(BuildContext context) => FocusScope.of(context).unfocus();
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String, String?) onChanged;
  final String? name;
  final String? hint;
  final EdgeInsets? padding;

  const PasswordField({super.key, required this.controller, required this.onChanged, this.name, this.hint, this.padding});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  TextEditingController get controller => widget.controller;
  void Function(String, String?) get onChanged => widget.onChanged;
  String get name => widget.name ?? "password";
  String get hint => widget.hint ?? "Password";
  EdgeInsets get padding => widget.padding ?? EdgeInsets.zero;

  bool _hidePassword = true;
  bool _isRunning = false;
  void _changePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _showPassword() {
    _changePasswordVisibility();
    if(!_hidePassword) {
      _isRunning = true;
      Timer(const Duration(seconds: 4), () {
        if(_isRunning && !_hidePassword) {
          _changePasswordVisibility();
          _isRunning = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: padding,
      child: FormBuilderTextField(
        controller: controller,
        name: name,
        decoration: InputDecoration(
            labelText: hint.toTitleCase(),
            hintText: hint.toLowerCase(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: _showPassword,
            ),
            border: InputFields.border,
            enabledBorder: InputFields.border
        ),
        obscureText: _hidePassword,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required()
        ]),
        onChanged: (value) => onChanged(name, value),
      ),
    );
  }
}

class UsernameField extends StatelessWidget {
  final void Function(String, String?) onChanged;
  final TextEditingController controller;
  final EdgeInsets? padding;
  const UsernameField({super.key, required this.controller, required this.onChanged, this.padding});

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: FormBuilderTextField(
        name: "username",
        controller: controller,
        onChanged: (value) => onChanged("username", value),
        decoration: InputDecoration(
          labelText: "Username",
          hintText: "username",
          prefixIcon: const Icon(Icons.person),
          border: InputFields.border,
          enabledBorder: InputFields.border
        ),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.minLength(4),
          FormBuilderValidators.match(r"^[A-z][A-z0-9]*$", errorText: "Username must start with letter and contains only letter and numbers."),
        ]),

      ),
    );
  }
}



class TextField extends StatelessWidget {
  final String name;
  final TextEditingController? controller;
  final void Function(String, String?)? onChanged;
  final List<FormFieldValidator<String?>>? validators;
  final String? hint;
  final EdgeInsets? padding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final InputBorder? border;
  final InputBorder? enableBorder;
  final bool showLabel;
  final int? maxLines;

  const TextField({
    super.key,
    required this.name,
    this.controller,
    this.onChanged,
    this.hint,
    this.validators,
    this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.formatters,
    this.border,
    this.enableBorder,
    this.showLabel = true,
    this.maxLines = 1
  });


  @override
  Widget build(BuildContext context) {
    final titleCase = name.toTitleCase();
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: FormBuilderTextField(
        maxLines: maxLines,
        onTapOutside: (event) => InputFields.unFocus(context),
        controller: controller,
        name: name,
        onChanged: (value) {
          if(onChanged != null) {
            onChanged!(name, value);
          }
        },
        decoration: InputDecoration(
          labelText: showLabel ? titleCase : null,
          hintText: hint ?? titleCase,
          border: border ?? InputFields.border,
          enabledBorder: enableBorder ?? InputFields.border,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon
        ),
        validator: validators != null ? FormBuilderValidators.compose(validators!) : null,
        keyboardType: keyboardType,
        inputFormatters: formatters,
      ),
    );
  }
}


class ShowField extends StatelessWidget {
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final Color? background;
  final Widget text;
  final double? circularRadius;
  const ShowField({
    super.key,
    this.padding,
    this.height,
    this.width,
    this.background,
    required this.text,
    this.circularRadius
  });

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: padding ?? EdgeInsets.zero,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(circularRadius ?? 5),
              color: background
          ),
          alignment: Alignment.centerLeft,
          child: text,
        )
    );
  }
}