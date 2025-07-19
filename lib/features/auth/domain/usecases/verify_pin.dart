import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPin {
  final AuthRepository repository;

  const VerifyPin(this.repository);

  Future<Either<Failure, bool>> call(VerifyPinParams params) async {
    return await repository.verifyPin(params.pin);
  }
}

class VerifyPinParams extends Equatable {
  final String pin;

  const VerifyPinParams({required this.pin});

  @override
  List<Object> get props => [pin];
}
