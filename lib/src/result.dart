import 'package:equatable/equatable.dart' show Equatable;

/// A generic class representing the result of an operation that can either succeed or fail.
///
/// This class uses a closed (sealed) class hierarchy (with [Success] and [Failure] being the only valid subtypes)
/// to enforce handling of both success and error cases at compile time. It provides a set of utility methods and getters:
///
/// - **Transformation**: Use [map] to transform a successful value while preserving errors.
/// - **Access**: [getOrThrow] returns the value or throws an error, and [getOrElse] provides a fallback value.
/// - **Reduction**: [fold] reduces the result into a single value by handling both success and failure paths.
/// - **Inspection**: [isSuccess] and [isFailure] allow quick runtime checking of the result state.
/// - **Safe Extraction**: [valueOrNull] and [errorOrNull] offer nullable versions of the success value or error.
///
/// Type Parameters:
/// - [S]: The type of the successful value.
/// - [E]: The type of the exception for failures, which extends [Exception].
///
/// Example usage:
/// ```dart
/// // Using Success:
/// final success = Success<double, Exception>(3.14);
/// print(success.getOrThrow()); // Output: 3.14
///
/// // Using Failure:
/// final failure = Failure<double, Exception>(Exception('Calculation error'));
/// print(failure.getOrElse(0.0)); // Output: 0.0
///
/// // Transforming a result:
/// final result = success.map((value) => 'Value is: $value');
/// print(result.getOrThrow()); // Output: Value is: 3.14
///
/// // Folding the result:
/// final message = failure.fold(
///   (value) => 'Success with $value',
///   (error) => 'Failure: ${error.toString()}'
/// );
/// print(message); // Output: Failure: Exception: Calculation error
/// ```
sealed class Result<S, E extends Exception> extends Equatable {
  const Result();

  /// Transforms the success value of type [S] using the provided [mapper] function.
  /// If the result is a [Success], the mapper is applied; if it's a [Failure],
  /// the error is preserved.
  ///
  /// Example:
  /// ```dart
  /// final result = Success<int, Exception>(10);
  /// final stringResult = result.map((value) => 'Number: $value');
  /// print(stringResult.getOrThrow()); // Output: Number: 10
  /// ```
  Result<T, E> map<T>(T Function(S value) mapper);

  /// Returns the success value if this [Result] is a [Success].
  /// If this is a [Failure], it throws the associated error.
  ///
  /// Example:
  /// ```dart
  /// final success = Success<String, Exception>('Hello');
  /// print(success.getOrThrow()); // Output: Hello
  /// ```
  S getOrThrow();

  /// Returns the success value if available; otherwise, returns the provided [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// final failure = Failure<String, Exception>(Exception('Oops'));
  /// print(failure.getOrElse('Default')); // Output: Default
  /// ```
  S getOrElse(S defaultValue);

  /// Reduces this [Result] into a single value.
  /// If the result is a [Success], the [onSuccess] function is applied to the value.
  /// If it is a [Failure], the [onFailure] function is applied to the error.
  ///
  /// Example:
  /// ```dart
  /// final result = Failure<int, Exception>(Exception('Failed'));
  /// final message = result.fold(
  ///   (value) => 'Value is $value',
  ///   (error) => 'Error occurred: ${error.toString()}'
  /// );
  /// print(message); // Output: Error occurred: Exception: Failed
  /// ```
  T fold<T>(T Function(S value) onSuccess, T Function(E error) onFailure);

  /// Returns true if this result is a success.
  bool get isSuccess => this is Success<S, E>;

  /// Returns true if this result is a failure.
  bool get isFailure => this is Failure<S, E>;

  /// Returns the success value if this is a [Success], otherwise returns `null`.
  S? get valueOrNull =>
      this is Success<S, E> ? (this as Success<S, E>).value : null;

  /// Returns the error if this is a [Failure], otherwise returns `null`.
  E? get errorOrNull =>
      this is Failure<S, E> ? (this as Failure<S, E>).error : null;
}

/// Represents a successful outcome of an operation, containing a value of type [S].
///
/// This class extends [Result] and signifies that an operation has completed successfully,
/// yielding a result of type [S]. The associated error type [E] extends [Exception].
///
/// Type Parameters:
/// - [S]: The type of the successful result.
/// - [E]: The type of the error, extending [Exception].
///
/// Example usage with different types:
///
/// ```dart
/// // Example 1: Using Success with an integer result
/// final result = Success<int, Exception>(42);
/// print(result.value); // Output: 42
///
/// // Example 2: Using Success with a string result
/// final result = Success<String, Exception>('Operation completed');
/// print(result.value); // Output: Operation completed
///
/// // Example 3: Using Success with a list of doubles
/// final result = Success<List<double>, Exception>([1.0, 2.5, 3.8]);
/// print(result.value); // Output: [1.0, 2.5, 3.8]
///
/// // Example 4: Using Success with a custom User object
/// final result = Success<User, Exception>(User('Alice', 30));
/// print(result.value.name); // Output: Alice
/// ```
final class Success<S, E extends Exception> extends Result<S, E> {
  /// The successful result value.
  ///
  /// This property holds the value produced by a successful operation.
  /// Its type is defined by the generic parameter [S].
  ///
  /// Example:
  ///
  /// ```dart
  /// class Product {
  ///   final String id;
  ///   final String name;
  ///   Product(this.id, this.name);
  /// }
  ///
  /// // Creating a Success with a Product:
  /// final success = Success<Product, Exception>(Product('P123', 'Wireless Headphones'));
  /// print(success.value);
  /// // Output: Product(id: P123, name: Wireless Headphones)
  /// ```
  final S value;
  const Success(this.value);

  @override
  Result<T, E> map<T>(T Function(S value) mapper) =>
      Success<T, E>(mapper(value));

  @override
  S getOrThrow() => value;

  @override
  S getOrElse(S defaultValue) => value;

  @override
  T fold<T>(T Function(S value) onSuccess, T Function(E error) onFailure) =>
      onSuccess(value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed outcome of an operation, containing an error of type [E].
///
/// This class extends [Result] and signifies that an operation has failed,
/// yielding an error of type [E]. The associated success type [S] is still specified
/// to maintain consistency with the [Result] interface.
///
/// Type Parameters:
/// - [S]: The type of the successful result (not used in this class but required for consistency).
/// - [E]: The type of the error, extending [Exception].
///
/// Example usage with different error types:
///
/// ```dart
/// // Example 1: Using Failure with a generic Exception
/// final result = Failure<int, Exception>(Exception('An error occurred'));
/// print(result.error); // Output: Exception: An error occurred
///
/// // Example 2: Using Failure with a FormatException
/// final result = Failure<String, FormatException>(FormatException('Invalid format'));
/// print(result.error); // Output: FormatException: Invalid format
///
/// // Example 3: Using Failure with a custom DatabaseException
/// final result = Failure<List<double>, DatabaseException>(DatabaseException('Database error'));
/// print(result.error.message); // Output: Database error
///
/// // Example 4: Using Failure with a TimeoutException
/// final result = Failure<User, TimeoutException>(TimeoutException('Operation timed out'));
/// print(result.error.message); // Output: Operation timed out
/// ```
final class Failure<S, E extends Exception> extends Result<S, E> {
  /// The error resulting from a failed operation.
  ///
  /// This property holds the exception that describes the reason for the failure.
  /// Its type is defined by the generic parameter [E], which extends [Exception].
  ///
  /// Example:
  ///
  /// Define a custom exception:
  /// ```dart
  /// class DatabaseException implements Exception {
  ///   final String message;
  ///   DatabaseException(this.message);
  ///
  ///   @override
  ///   String toString() => 'DatabaseException: $message';
  /// }
  /// ```
  ///
  /// Use case with a custom type (e.g., a Product model):
  /// ```dart
  /// class Product {
  ///   final String id;
  ///   final String name;
  ///   Product(this.id, this.name);
  /// }
  ///
  /// // Creating a Failure with a custom DatabaseException:
  /// final failure = Failure<Product, DatabaseException>(
  ///   DatabaseException('Unable to retrieve product data')
  /// );
  /// print(failure.error);
  /// // Output: DatabaseException: Unable to retrieve product data
  /// ```
  final E error;
  const Failure(this.error);

  @override
  Result<T, E> map<T>(T Function(S value) mapper) => Failure<T, E>(error);

  @override
  S getOrThrow() => throw error;

  @override
  S getOrElse(S defaultValue) => defaultValue;

  @override
  T fold<T>(T Function(S value) onSuccess, T Function(E error) onFailure) =>
      onFailure(error);

  @override
  List<Object?> get props => [error];

  @override
  String toString() => 'Failure($error)';
}

/// Extension methods for handling asynchronous operations that return a [Result].
///
/// Provides convenient methods to transform or chain operations on a [Future] that resolves to a [Result].
extension FutureResultExtension<S, E extends Exception>
    on Future<Result<S, E>> {
  /// Transforms the success value of this future result using the provided [mapper] function.
  ///
  /// If the result is a [Success], applies [mapper] to its value.
  /// If the result is a [Failure], the error is preserved.
  ///
  /// Example:
  /// ```dart
  /// Future<Result<int, Exception>> fetchNumber() async => Success(10);
  ///
  /// void main() async {
  ///   final result = await fetchNumber().mapAsync((value) => 'Number: $value');
  ///   print(result.getOrThrow()); // Output: Number: 10
  /// }
  /// ```
  Future<Result<T, E>> mapAsync<T>(T Function(S value) mapper) async {
    final result = await this;
    return result.map(mapper);
  }

  /// Chains another asynchronous operation that returns a [Result], based on the success value of this future result.
  ///
  /// If the result is a [Success], applies [mapper] to its value.
  /// If the result is a [Failure], the error is preserved.
  ///
  /// Example:
  /// ```dart
  /// Future<Result<int, Exception>> fetchNumber() async => Success(10);
  /// Future<Result<String, Exception>> fetchString(int number) async => Success('Number: $number');
  ///
  /// void main() async {
  ///   final result = await fetchNumber().flatMapAsync(fetchString);
  ///   print(result.getOrThrow()); // Output: Number: 10
  /// }
  /// ```
  Future<Result<T, E>> flatMapAsync<T>(
      Future<Result<T, E>> Function(S value) mapper) async {
    final result = await this;
    if (result is Success<S, E>) {
      return await mapper(result.value);
    } else {
      return Failure<T, E>((result as Failure<S, E>).error);
    }
  }
}

/// Creates a [Success] instance containing the provided [value].
///
/// Useful for wrapping a successful operation result.
///
/// Example:
/// ```dart
/// final result = success<int, Exception>(42);
/// print(result.getOrThrow()); // Output: 42
/// ```
Result<S, E> success<S, E extends Exception>(S value) => Success<S, E>(value);

/// Creates a [Failure] instance containing the provided [error].
///
/// Useful for wrapping a failed operation result.
///
/// Example:
/// ```dart
/// final result = failure<int, Exception>(Exception('An error occurred'));
/// print(result.isFailure); // Output: true
/// ```
Result<S, E> failure<S, E extends Exception>(E error) => Failure<S, E>(error);

/// Executes a synchronous function [fn] and wraps its result in a [Result].
///
/// If [fn] executes without throwing, returns a [Success] containing the result.
/// If [fn] throws an exception, applies [onError] to the exception and returns a [Failure].
///
/// Example:
/// ```dart
/// int computeValue() {
///   // Some computation that might throw
///   return 42;
/// }
///
/// void main() {
///   final result = tryResult<int, Exception>(
///     computeValue,
///     (error) => Exception('Computation failed: $error'),
///   );
///   print(result.getOrElse(0)); // Output: 42
/// }
/// ```
Result<S, E> tryResult<S, E extends Exception>(
  S Function() fn,
  E Function(dynamic error) onError,
) {
  try {
    return Success<S, E>(fn());
  } catch (e) {
    return Failure<S, E>(onError(e));
  }
}

/// Executes a synchronous function [fn] and wraps its result in a [Result],
/// specifically handling [Exception] types.
///
/// This function is similar to [tryResult], but it specifically catches only
/// exceptions that are instances of [Exception], ignoring other error types.
/// If [fn] executes without throwing an [Exception], returns a [Success] containing the result.
/// If [fn] throws an [Exception], applies [onError] to transform the exception and returns a [Failure].
///
/// Type Parameters:
/// - [S]: The type of the successful value.
/// - [E]: The specific [Exception] type to catch (must extend [Exception]).
///
/// Parameters:
/// - [fn]: The function to execute that might throw an [Exception].
/// - [onError]: Function that transforms the caught exception into the desired error type.
///
/// Returns:
/// A [Result] containing either the successful value or the transformed error.
///
/// Example:
/// ```dart
/// // Define a custom exception
/// class ValidationException implements Exception {
///   final String message;
///   ValidationException(this.message);
///
///   @override
///   String toString() => 'ValidationException: $message';
/// }
///
/// // Function that validates user input
/// Result<String, Exception> validateUsername(String username) {
///   return tryResultE(
///     () {
///       if (username.isEmpty) {
///         throw ValidationException('Username cannot be empty');
///       }
///       if (username.length < 3) {
///         throw ValidationException('Username must be at least 3 characters');
///       }
///       return username;
///     },
///     (error) => error // Pass through the exception as is
///   );
/// }
///
/// void main() {
///   final result = validateUsername('');
///   if (result.isFailure) {
///     print(result.errorOrNull); // Output: ValidationException: Username cannot be empty
///   }
///
///   final validResult = validateUsername('john');
///   print(validResult.getOrThrow()); // Output: john
/// }
/// ```
Result<S, Exception> tryResultE<S, E extends Exception>(
  S Function() fn,
  Exception Function(Exception error) onError,
) {
  try {
    return Success<S, Exception>(fn());
  } on Exception catch (e) {
    return Failure<S, Exception>(onError(e));
  }
}

/// Executes an asynchronous function [fn] and wraps its result in a [Result].
///
/// If [fn] completes without throwing, returns a [Success] containing the result.
/// If [fn] throws an exception, applies [onError] to the exception and returns a [Failure].
///
/// Example:
/// ```dart
/// Future<int> fetchValue() async {
///   // Some asynchronous operation that might throw
///   return 42;
/// }
///
/// void main() async {
///   final result = await tryResultAsync<int, Exception>(
///     fetchValue,
///     (error) => Exception('Fetching failed: $error'),
///   );
///   print(result.getOrElse(0)); // Output: 42
/// }
/// ```
Future<Result<S, E>> tryResultAsync<S, E extends Exception>(
  Future<S> Function() fn,
  E Function(dynamic error) onError,
) async {
  try {
    return Success<S, E>(await fn());
  } catch (e) {
    return Failure<S, E>(onError(e));
  }
}

/// Executes an asynchronous function [fn] and wraps its result in a [Result],
/// specifically handling [Exception] types.
///
/// This function is the asynchronous variant of [tryResultE]. It catches only
/// exceptions that are instances of [Exception], ignoring other error types.
/// If [fn] completes without throwing an [Exception], returns a [Success] containing the result.
/// If [fn] throws an [Exception], applies [onError] to transform the exception and returns a [Failure].
///
/// Type Parameters:
/// - [S]: The type of the successful value.
/// - [E]: The specific [Exception] type to catch (must extend [Exception]).
///
/// Parameters:
/// - [fn]: The asynchronous function to execute that might throw an [Exception].
/// - [onError]: Function that transforms the caught exception into the desired error type.
///
/// Returns:
/// A [Future] that completes with a [Result] containing either the successful value or the transformed error.
///
/// Example:
/// ```dart
/// // Define custom exceptions
/// class NetworkException implements Exception {
///   final String message;
///   NetworkException(this.message);
///
///   @override
///   String toString() => 'NetworkException: $message';
/// }
///
/// class AuthException implements Exception {
///   final String message;
///   AuthException(this.message);
///
///   @override
///   String toString() => 'AuthException: $message';
/// }
///
/// // Function that simulates fetching user profile
/// Future<Result<Map<String, dynamic>, Exception>> fetchUserProfile(String userId) {
///   return tryResultAsyncE(
///     () async {
///       await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
///
///       if (userId.isEmpty) {
///         throw AuthException('User ID is required');
///       }
///
///       if (!isConnected) { // Assume isConnected is a global connectivity state
///         throw NetworkException('No internet connection');
///       }
///
///       // Simulate successful API response
///       return {
///         'id': userId,
///         'name': 'John Doe',
///         'email': 'john@example.com',
///         'lastLogin': DateTime.now().toIso8601String(),
///       };
///     },
///     (error) {
///       // Transform or pass through exceptions based on their type
///       if (error is NetworkException) {
///         return error;
///       } else if (error is AuthException) {
///         return error;
///       } else {
///         return Exception('Unknown error occurred: ${error.toString()}');
///       }
///     }
///   );
/// }
///
/// void main() async {
///   // Example usage
///   final result = await fetchUserProfile('user123');
///
///   result.fold(
///     (profile) => print('User profile loaded: ${profile['name']}'),
///     (error) {
///       if (error is NetworkException) {
///         print('Connection error: ${error.message}');
///       } else if (error is AuthException) {
///         print('Authentication error: ${error.message}');
///       } else {
///         print('Error: ${error.toString()}');
///       }
///     }
///   );
/// }
/// ```
Future<Result<S, Exception>> tryResultAsyncE<S, E extends Exception>(
  Future<S> Function() fn,
  Exception Function(Exception error) onError,
) async {
  try {
    return Success<S, Exception>(await fn());
  } on Exception catch (e) {
    return Failure<S, Exception>(onError(e));
  }
}
