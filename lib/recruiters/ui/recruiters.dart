import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/recruiters/ui/recruiter_profile.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class ListRecruiters extends StatelessWidget {
  final List<Recruiter> recruiters;
  final String companyName;
  const ListRecruiters({super.key, required this.recruiters, required this.companyName});

  static void toRecruiterProfile(BuildContext context, {required Recruiter recruiter, bool companyAction = true}) {
    Navegations.persistentTo(context,
      widget: RecruiterProfile(recruiter: recruiter, companyAction: companyAction,)
    );
  }

  Widget _recruiter(BuildContext context, Recruiter recruiter) => AppTile(
    onTap: () => toRecruiterProfile(context, recruiter: recruiter, companyAction: false),
    leading: ImageUtils.avatar(url: recruiter.account.imageUrl),
    title: Text("${recruiter.account.firstname} ${recruiter.account.lastname}"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context,
        widTitle: MarqueeText(
          speed: 50,
          text: TextSpan(
            text: "$companyName's recruiters",
            style: const TextStyle(color: Colors.white)
          ),
        ),
        leading: ZenDrivers.back(context)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: recruiters.map((e) => _recruiter(context, e)).toList(),
        ),
      ),
    );
  }
}
