import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../../features/auth/domain/entities/user.dart';

// Authentication types
typedef AuthResult = Either<Failure, void>;
typedef AuthUserResult = Either<Failure, User>;
typedef BiometricResult = Either<Failure, bool>;

// Validation types
typedef ValidationResult = Either<ValidationFailure, String>;

// Storage types
typedef StorageResult = Either<StorageFailure, String>;
typedef StorageBoolResult = Either<StorageFailure, bool>;

// Network types
typedef NetworkResult<T> = Either<NetworkFailure, T>;
