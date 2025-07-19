import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;

  const SignUpWithEmail(this.repository);

  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(params.email, params.password);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
