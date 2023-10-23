part of 'account_profile.dart';

class _ChangePasswordDialog extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _newConfirmPassword = TextEditingController();
  final _accountService = AccountService();
  final _logout = MutableObject(false);
  _ChangePasswordDialog();

  void _validate(String name, String? value) => _formKey.currentState?.fields[name]?.validate();

  Widget _changeButton(BuildContext context) => AppAsyncButton(
    future: () async {
      if(_formKey.currentState?.validate() ?? false) {
        final fields = _formKey.currentState?.fields.map((key, value) => MapEntry(key, value.value));
        if(fields != null) {
          final request = ChangePasswordRequest.fromJson(fields);
          return _accountService.changePassword(request);
        }
      }

      return MessageResponse.empty();
    },
    onSuccess: (response) {
      if(response.valid) {
        if(_logout.value) {
          _accountService.preferences.removeCredentials().then((value) => Navegations.persistentReplace(context, widget: LoginPage()));
        }
        else {
          AppToast.show(context, response.message);
          Navegations.back(context);
        }
      }
      else {
        AppToast.show(context, response.isEmpty ? "Fill all the fields" : "Password incorrect");
      }
    },
    child: const Text("Change"),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24, top: 16, right: 24, bottom: 8),
      actions: [
        AppButton(
          onClick: () => Navegations.back(context),
          child: const Text("Cancel"),
        ),
        _changeButton(context)
      ],
      backgroundColor: Colors.white,
      content: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            fields.PasswordField(
              controller: _currentPassword,
              name: "currentPassword",
              hint: "Current password",
              label: "Current password",
              onChanged: _validate,
              padding: AppPadding.bottom(value: 12),
            ),
            fields.PasswordField(
              controller: _newPassword,
              name: "newPassword",
              hint: "New password",
              label: "New password",
              onChanged: _validate,
              padding: AppPadding.bottom(value: 12),
            ),
            fields.PasswordField(
              controller: _newConfirmPassword,
              name: "confirmNewPassword",
              hint: "Confirm new password",
              label: "Confirm new password",
              onChanged: (name, value) {
                final field = _formKey.currentState?.fields[name];
                if(field?.validate() ?? false) {
                  if(_newConfirmPassword.text != _newPassword.text) {
                    field?.invalidate("Must be equal to new password");
                  }
                }
              },
            ),
            _LogoutCheckbox(
              value: _logout.value,
              onChanged: (value) => _logout.value = value,
            )
          ],
        ),
      ),
    );
  }
}

class _LogoutCheckbox extends StatefulWidget {
  final bool value;
  final void Function(bool) onChanged;
  const _LogoutCheckbox({this.value = false, required this.onChanged});

  @override
  State<_LogoutCheckbox> createState() => _LogoutCheckboxState();
}

class _LogoutCheckboxState extends State<_LogoutCheckbox> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          shape: const CircleBorder(
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
          value: _isChecked,
          onChanged: (value) {
            if(value != null) {
              setState(() {
                _isChecked = value;
              });
              widget.onChanged(value);
            }
          },
        ),
        Text("Logout after change",
          style: AppText.paragraph,
        )
      ],
    );
  }
}
