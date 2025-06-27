import 'package:gym/models/member.dart';
import 'package:gym/models/membership_package.dart';
import 'package:gym/models/payment.dart';
import 'package:gym/models/setting.dart';
import 'package:gym/models/subscription.dart';

class Receipt {
  final Payment payment;
  final Subscription subscription;
  final Member member;
  final MembershipPackage package;
  final Setting setting;
  final String receiptNumber;
  final DateTime receiptDate;

  Receipt({
    required this.payment,
    required this.subscription,
    required this.member,
    required this.package,
    required this.setting,
    required this.receiptNumber,
    required this.receiptDate,
  });
}
