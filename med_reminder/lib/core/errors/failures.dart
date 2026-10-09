/// Base Failure class for Clean Architecture.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error occurred']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Requested item not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

class NotificationFailure extends Failure {
  const NotificationFailure([super.message = 'Failed to schedule notification']);
}
