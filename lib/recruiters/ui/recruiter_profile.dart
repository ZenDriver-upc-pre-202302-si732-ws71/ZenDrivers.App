import 'package:flutter/material.dart';
import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/recruiters/services/post.dart';
import 'package:zendrivers/recruiters/services/recruiter.dart';
import 'package:zendrivers/recruiters/ui/posts.dart';
import 'package:zendrivers/recruiters/ui/recruiters.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class RecruiterProfile extends StatelessWidget {
  final Recruiter recruiter;
  final _postService = PostService();
  final _recruiterService = RecruiterService();
  final bool companyAction;
  RecruiterProfile({super.key, required this.recruiter, this.companyAction = true});

  Widget _showFieldSpacer() =>  AppPadding.widget(padding: AppPadding.topAndBottom(value: 5));
  Widget _showTextField(String text) => ShowField(
    text: AppPadding.widget(
        padding: AppPadding.horAndVer(vertical: 5),
        child: Text(text,
          style: AppText.paragraph,
        )
    ),
    background: Colors.white,
    padding: AppPadding.right(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context,
        title: "Recruiter ${recruiter.account.firstname}",
        leading: ZenDrivers.back(context)
      ),
      body: SingleChildScrollView(
        child: AppPadding.widget(
          padding: AppPadding.horAndVer(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.primary,
                elevation: 2,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ZenDrivers.profile(recruiter.account.imageUrl ?? ZenDrivers.defaultProfileUrl,
                        height: 200
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          _showFieldSpacer(),
                          _showTextField(recruiter.account.firstname),
                          _showFieldSpacer(),
                          _showTextField(recruiter.account.lastname),
                          _showFieldSpacer(),
                          _showTextField(recruiter.description),
                          _showFieldSpacer(),
                          _showTextField(recruiter.account.phone),
                          _showFieldSpacer(),
                          _showTextField(recruiter.email),
                          _showFieldSpacer(),
                          if(companyAction)
                            AppAsyncButton(
                              future: () => _recruiterService.getByCompanyId(recruiter.company.id),
                              onSuccess: (value) => Navegations.persistentTo(context, widget: ListRecruiters(
                                recruiters: value,
                                companyName: recruiter.company.name,
                              )),
                              child: SizedBox(
                                width: 100,
                                child: Text(recruiter.company.name, overflow: TextOverflow.ellipsis,),
                              ),
                            ),
                          if(!companyAction)
                            _showTextField(recruiter.company.name),
                          if(!companyAction)
                            _showFieldSpacer(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              AppPadding.widget(
                padding: AppPadding.leftAndRight(),
                child: Text("Posts", style: AppText.title,)
              ),
              RichFutureBuilder(
                future: _postService.getFrom(recruiter.account.username),
                builder: (posts) => _RecruiterPosts(
                  posts: posts,
                  credentials: _postService.preferences.getCredentials(),
                )
              )
            ],
          )
        ),
      ),
    );
  }
}


class _RecruiterPosts extends StatefulWidget {
  final List<Post> posts;
  final LoginResponse credentials;
  const _RecruiterPosts({super.key, required this.posts, required this.credentials});

  @override
  State<_RecruiterPosts> createState() => _RecruiterPostsState();
}

class _RecruiterPostsState extends State<_RecruiterPosts> {
  List<Post> get posts => widget.posts;

  @override
  void initState() {
    posts.sort((a, b) => b.date.compareTo(a.date));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return posts.isEmpty ? const Text("Nothing to show") : OverflowColumn(
      maxItems: 5,
      items: posts.map((e) => PostView(
          key: ObjectKey(e),
          post: e,
          showComments: false,
          postEdited: (source, updated) {
            posts.replaceFor(source, updated);
          },
          postDeleted: (post) {
            setState(() {
              posts.remove(post);
            });
          },
        ),
      ),
    );
  }
}
