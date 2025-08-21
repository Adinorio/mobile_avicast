import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn(String userId, String password);
  Future<Either<Failure, User>> signUp(String userId, String password, String name);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isSignedIn();
  Future<Either<Failure, void>> forgotPassword(String userId);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
  Future<Either<Failure, User>> updateProfile(User user);
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);
} 