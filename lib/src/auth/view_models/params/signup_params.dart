import 'package:equatable/equatable.dart';

class SignUpParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String phoneNumber;
  final String address;

  const SignUpParams({
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.address,
  });

  @override
  List<Object?> get props => [username, email, password, phoneNumber, address];
}
