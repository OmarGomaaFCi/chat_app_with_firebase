part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthGoogleSignInLoadingState extends AuthState {}

class AuthGoogleSignInFirebaseErrorState extends AuthState {
  final String message;

  AuthGoogleSignInFirebaseErrorState(this.message);
}

class AuthGoogleSignInNoInternetState extends AuthState{}
class AuthGoogleSignInSuccessState extends AuthState {
  final User user;

  AuthGoogleSignInSuccessState(this.user);
}
