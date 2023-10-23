import 'dart:async';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:http/http.dart' as http;
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';


class InputFields {
  static InputBorder get border => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.lightBlueAccent)
  );
  static void unFocus(BuildContext context) => FocusScope.of(context).unfocus();

  static Icon person({Color? color, double? size}) => Icon(FluentIcons.person_32_regular,
    color: color,
    size: size,
  );

  static Icon lock({bool on = true, Color? color, double? size}) => Icon(on ? FluentIcons.lock_closed_32_regular : FluentIcons.lock_open_32_regular,
    color: color,
    size: size,
  );

  static Icon visible({bool on = true, Color? color, double? size}) => Icon(on ? FluentIcons.eye_32_regular : FluentIcons.eye_32_filled,
    color: color,
    size: size,
  );

  static Icon phone({Color? color, double? size}) => Icon(FluentIcons.phone_32_regular,
    color: color,
    size: size,
  );

  static Icon home({Color? color, double? size}) => Icon(FluentIcons.home_32_regular,
    color: color,
    size: size,
  );
}

class NamedTextField extends StatelessWidget {
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
  final int? minLines;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final void Function(PointerDownEvent)? onTapOutside;
  final String? label;
  final FocusNode? focusNode;
  final bool obscureText;
  const NamedTextField({
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
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTapOutside,
    this.label,
    this.focusNode,
    this.obscureText = false
  });


  @override
  Widget build(BuildContext context) {
    final titleCase = name.toTitleCase();
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: FormBuilderTextField(
        focusNode: focusNode,
        readOnly: readOnly,
        maxLines: maxLines,
        minLines: minLines,
        textCapitalization: textCapitalization,
        onTapOutside: onTapOutside ?? (event) => InputFields.unFocus(context),
        controller: controller,
        name: name,
        onChanged: (value) {
          if(onChanged != null) {
            onChanged!(name, value);
          }
        },
        decoration: InputDecoration(
          labelText: showLabel ? (label ?? titleCase) : null,
          hintText: hint ?? titleCase,
          border: border ?? InputFields.border,
          enabledBorder: enableBorder ?? InputFields.border,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon
        ),
        validator: validators != null ? FormBuilderValidators.compose(validators!) : null,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        obscureText: obscureText,
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String, String?) onChanged;
  final String? name;
  final String? hint;
  final EdgeInsets? padding;
  final Duration showDuration;

  const PasswordField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.name,
    this.hint,
    this.padding,
    this.showDuration = const Duration(seconds: 4)
  });

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
      Timer(widget.showDuration, () {
        if(_isRunning && !_hidePassword) {
          _changePasswordVisibility();
          _isRunning = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NamedTextField(
      padding: padding,
      controller: controller,
      name: name,
      prefixIcon: InputFields.lock(on: _hidePassword),
      suffixIcon: IconButton(
        icon: InputFields.visible(on: _hidePassword),
        onPressed: _showPassword,
      ),
      obscureText: _hidePassword,
      validators: [
        FormBuilderValidators.required(),
        FormBuilderValidators.minLength(4, errorText: "Min length is 4")
      ],
      onChanged: onChanged,
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
    return NamedTextField(
      name: "username",
      controller: controller,
      onChanged: onChanged,
      hint: "username",
      padding: padding,
      prefixIcon: InputFields.person(),
      validators: [
        FormBuilderValidators.required(),
        FormBuilderValidators.minLength(4),
        FormBuilderValidators.match(r"^[A-z][A-z0-9]*$", errorText: "Username must start with letter and contains only letter and numbers."),
      ],
    );
  }
}


class ShowField extends StatelessWidget {
  final EdgeInsets? padding;
  final EdgeInsets? containerPadding;
  final double? height;
  final double? width;
  final Color? background;
  final Widget text;
  final double? circularRadius;
  final BoxDecoration? decoration;
  const ShowField({
    super.key,
    this.padding,
    this.height,
    this.width,
    this.background,
    required this.text,
    this.circularRadius,
    this.decoration,
    this.containerPadding
  });

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: padding ?? EdgeInsets.zero,
        child: Container(
          height: height,
          width: width,
          padding: containerPadding,
          decoration: decoration ?? BoxDecoration(
            borderRadius: BorderRadius.circular(circularRadius ?? 5),
            color: background
          ),
          alignment: Alignment.centerLeft,
          child: text,
        )
    );
  }
}

class ImageUrlField extends StatefulWidget {
  final String name;
  final TextEditingController? controller;
  final void Function(String, String?)? onUrlSuccessOrEmpty;
  final InputBorder? border;
  final InputBorder? enableBorder;
  final bool showLabel;
  final int? maxLines;
  final int? minLines;
  final ImageUrlFieldType type;
  final Widget Function(String)? imageBuilder;
  final String? hint;
  final String? label;
  final void Function(String, String)? onUrlError;
  const ImageUrlField({
    super.key,
    required this.name,
    this.onUrlSuccessOrEmpty,
    this.border,
    this.enableBorder,
    this.showLabel = true,
    this.maxLines = 2,
    this.minLines,
    this.imageBuilder,
    this.type = ImageUrlFieldType.prefix,
    this.controller,
    this.hint,
    this.label,
    this.onUrlError,
  });

  @override
  State<ImageUrlField> createState() => _ImageUrlFieldState();
}

class _ImageUrlFieldState extends State<ImageUrlField> {

  bool get isPrefix => widget.type == ImageUrlFieldType.prefix;
  bool get hasBuilder => builder != null;
  Widget Function(String)? get builder => widget.imageBuilder;
  bool _isFocus = true;
  String? url;


  @override
  void initState() {
    super.initState();
    url = widget.controller?.text;
  }
  void _callOnSuccess() {
    if(widget.onUrlSuccessOrEmpty != null) {
      widget.onUrlSuccessOrEmpty!(widget.name, url);
    }
  }

  Widget _default(Widget icon) {
    _callOnSuccess();
    return icon;
  }

  Widget _prefixImage() {
    if(isPrefix) {
      return hasBuilder ? builder!(url!) : ImageUtils.avatar(
        url: url,
        padding: AppPadding.leftAndRight(),
        avatarBuilder: (url, radius, defaultIcon) => CircleAvatar(
          backgroundColor: Colors.transparent,
          child: url != null && url.isValidUrl() ? RichFutureBuilder(
            future: http.get(Uri.parse(url)),
            builder: (response) {
              if(response.isOk) {
                _callOnSuccess();
                return ImageUtils.avatar(url: url, radius: radius + 5);
              }
              return defaultIcon;
            },
            errorChild: () {
              if(widget.onUrlError != null) {
                widget.onUrlError!(widget.name, url);
              }
              return defaultIcon;
            },
            showException: false,
          ) : _default(defaultIcon),
        )
      );
    }

    return Container();
  }
  Widget _image() {
    if(!isPrefix && url != null) {
      return hasBuilder ? builder!(url!) : ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ImageUtils.net(url!, loading: ImageUtils.loading),
      );
    }
    return Container();
  }

  void _onChange(String name, String? value) {
    setState(() {
      url = value;
    });
  }

  void changeFocus() {
    if(!isPrefix) {
      setState(() {
        _isFocus = !_isFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isFocus ? NamedTextField(
      controller: widget.controller,
      name: widget.name,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      showLabel: widget.showLabel,
      prefixIcon: _prefixImage(),
      onChanged: _onChange,
      border: widget.border,
      enableBorder: widget.enableBorder,
      hint: widget.hint,
      label: widget.label,
      validators: [
        FormBuilderValidators.url(),
      ],
    ) : InkWell(
      onTap: changeFocus,
      child: _image(),
    );
  }
}

enum ImageUrlFieldType {
  prefix,
  replace
}