sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Object error) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failure<T>) return failure(self.error);
    throw StateError('Unhandled Result variant');
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final Object error;
}
