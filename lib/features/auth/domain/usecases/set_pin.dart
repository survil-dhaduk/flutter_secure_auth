import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SetPin {
  final AuthRepository repository;

  const SetPin(this.repository);

  Future<Either<Failure, void>> call(SetPinParams params) async {
    return await repository.setPin(params.pin);
  }
}

class SetPinParams extends Equatable {
  final String pin;

  const SetPinParams({required this.pin});

  @override
  List<Object> get props => [pin];
}
