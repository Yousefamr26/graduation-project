import 'package:flutter/foundation.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final Map<String, dynamic> profileData;

  ProfileSuccess({required this.profileData});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
