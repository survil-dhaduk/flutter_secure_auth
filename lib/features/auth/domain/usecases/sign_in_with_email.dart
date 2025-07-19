import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmail(params.email, params.password);
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
