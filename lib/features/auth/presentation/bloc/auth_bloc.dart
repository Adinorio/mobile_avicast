import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/user_context_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.signIn(
        event.userId,
        event.password,
      );

      result.fold(
        (failure) {
          emit(AuthFailure(failure.message));
        },
        (user) {
          // Set user context for data isolation
          UserContextService.instance.setCurrentUserId(user.id);
          UserContextService.instance.setCurrentUserName(user.name);
          emit(Authenticated(user));
        },
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.signOut();

      result.fold(
        (failure) {
          emit(AuthFailure(failure.message));
        },
        (_) {
          // Clear user context
          UserContextService.instance.clearCurrentUser();
          emit(Unauthenticated());
        },
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.getCurrentUser();

      result.fold(
        (failure) {
          emit(Unauthenticated());
        },
        (user) {
          if (user != null) {
            // Set user context for data isolation
            UserContextService.instance.setCurrentUserId(user.id);
            UserContextService.instance.setCurrentUserName(user.name);
            emit(Authenticated(user));
          } else {
            emit(Unauthenticated());
          }
        },
      );
    } catch (e) {
      emit(Unauthenticated());
    }
  }
} 