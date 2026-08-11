sealed class Failure {
  const Failure({required this.message});

  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Something went wrong. Please try again.'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Check your network.'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Invalid username or password.'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Unexpected error occurred.'});
}
