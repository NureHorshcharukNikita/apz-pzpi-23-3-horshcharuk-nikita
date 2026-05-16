import 'package:elevate_mobile/domain/entities/team/member_badge_award.dart';

class MemberBadgeAwardModel {
  final int userTeamBadgeId;
  final int teamBadgeId;
  final String badgeName;
  final DateTime awardedAt;

  MemberBadgeAwardModel({
    required this.userTeamBadgeId,
    required this.teamBadgeId,
    required this.badgeName,
    required this.awardedAt,
  });

  factory MemberBadgeAwardModel.fromJson(Map<String, dynamic> json) {
    dynamic pick(String a, String b) => json[a] ?? json[b];

    final at = pick('awardedAt', 'AwardedAt');
    DateTime awarded;
    if (at is String) {
      awarded = DateTime.tryParse(at)?.toLocal() ?? DateTime.now();
    } else {
      awarded = DateTime.now();
    }

    int pInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    return MemberBadgeAwardModel(
      userTeamBadgeId: pInt(pick('userTeamBadgeId', 'UserTeamBadgeId')),
      teamBadgeId: pInt(pick('teamBadgeId', 'TeamBadgeId')),
      badgeName: '${pick('badgeName', 'BadgeName') ?? ''}',
      awardedAt: awarded,
    );
  }

  MemberBadgeAward toEntity() => MemberBadgeAward(
        userTeamBadgeId: userTeamBadgeId,
        teamBadgeId: teamBadgeId,
        badgeName: badgeName,
        awardedAt: awardedAt,
      );
}
