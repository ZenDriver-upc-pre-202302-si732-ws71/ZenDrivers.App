import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/recruiters/services/post.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';

class PostCreateView extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final _postService = PostService();
  final _imageUrl = MutableObject<String?>(null);
  PostCreateView({super.key});

  void _validateField(String name, String? value) => _formKey.currentState?.fields[name]?.validate();
  Future<EntityResponse<Post>> _createPost() async {
    if(_formKey.currentState?.validate() ?? false) {
      final fields = _formKey.currentState!.fields.map((key, value) => MapEntry(key, value.value));
      fields.putIfAbsent("image", () => _imageUrl.value);
      final request = PostSave.fromJson(fields);
      return _postService.createPost(request);
    }

    return EntityResponse.invalid(message: "Fill all the required fields");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context,
        leading: ZenDrivers.back(context)
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[
              NamedTextField(
                name: "title",
                label: "Post title",
                hint: "Post title",
                padding: AppPadding.all().copyWith(top: 15),
                onChanged: _validateField,
                prefixIcon: const Icon(FluentIcons.text_32_regular),
                validators: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.match("^[A-z0-9 '\",\\.\\?]*?\$", errorText: "The field has a invalid character")
                ],
              ),
              NamedTextField(
                name: "description",
                label: "Description",
                hint: "Description",
                onChanged: _validateField,
                padding: AppPadding.all(),
                maxLines: 6,
                validators: [
                  FormBuilderValidators.required(),
                  //FormBuilderValidators.minLength(50, errorText: "The description must be at least 50 characters long")
                ],

              ),
              AppPadding.widget(
                padding: AppPadding.all(),
                child: ImageUrlField(
                  name: "image",
                  label: "Image url",
                  hint: "Image url",
                  maxLines: 8,
                  onChange: _validateField,
                  type: ImageUrlFieldType.replace,
                  onUrlError: (name, value) {
                    _imageUrl.value = null;
                  },
                  onUrlSuccessOrEmpty: (name, value) {
                    _imageUrl.value = value;
                  },
                ),
              ),
              AppAsyncButton(
                future: _createPost,
                child: const Text("Create"),
                onSuccess: (response) {
                  if(response.isValid) {
                    Navegations.back(context, response.value);
                  }
                  else {
                    AppToast.show(context, response.message);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
