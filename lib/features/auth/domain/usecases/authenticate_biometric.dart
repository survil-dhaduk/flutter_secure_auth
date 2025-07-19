import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class AuthenticateBiometric {
  final AuthRepository repository;

  const AuthenticateBiometric(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.authenticateWithBiometric();
  }
}
