import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class EnableBiometric {
  final AuthRepository repository;

  const EnableBiometric(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.enableBiometric();
  }
}
