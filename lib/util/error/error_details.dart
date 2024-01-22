import 'package:json_annotation/json_annotation.dart';

part 'error_details.g.dart';

@JsonSerializable()
class ErrorDetails {
  final String stacktrace;
  final String exception;
  final String? library;
  final String? silent;
  final String? summary;
  final String? date;
  final String? currentUser;
  final String? appVersion;
  ErrorDetails(
    this.stacktrace,
    this.exception,
    this.library,
    this.silent,
    this.summary,
    this.date,
    this.currentUser,
    this.appVersion,
  );

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorDetailsToJson(this);
}
