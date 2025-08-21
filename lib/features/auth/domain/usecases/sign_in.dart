import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class SignInParams {
  final String userId;
  final String password;

  const SignInParams({
    required this.userId,
    required this.password,
  });
}

class SignIn implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signIn(params.userId, params.password);
  }
} 