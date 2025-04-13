# kib_utils

A Dart utility package that provides a variety of tools. 

Starting with the `Result` class for representing operations that can either succeed or fail, providing functional error handling.

## Features of Result

- `Result<S, E>` class with `Success` and `Failure` subclasses
- Utility functions for working with results
- Extensions for asynchronous operations
- Type-safe error handling without exceptions

## Getting started

```bash
dart pub add kib_utils
```

Or add to your `pubspec.yaml`:

```yaml
dependencies:
  kib_utils: ^1.0.0
```

## Usage of Result

### Basic usage

```dart
import 'package:kib_utils/kib_utils.dart';

void main() {
  // Create a success result
  final success = Success<int, Exception>(42);
  print(success.value); // 42
  
  // Create a failure result
  final failure = Failure<int, Exception>(Exception('Something went wrong'));
  print(failure.error); // Exception: Something went wrong
  
  // Using convenience functions
  final successResult = success<String, Exception>('It worked!');
  final failureResult = failure<String, Exception>(Exception('Oops!'));
}
```

### Transforming results

```dart
import 'package:kib_utils/kib_utils.dart';

void main() {
  final result = Success<int, Exception>(42);
  
  // Map a success value
  final mapped = result.map((value) => 'The answer is $value');
  print(mapped.getOrThrow()); // The answer is 42
  
  // Handle both cases with fold
  final message = result.fold(
    (value) => 'Success with value: $value',
    (error) => 'Failed with error: $error',
  );
  print(message); // Success with value: 42
}
```

### Working with asynchronous operations

```dart
import 'package:kib_utils/kib_utils.dart';

Future<void> main() async {
  // Try an async operation
  final result = await tryResultAsync<String, Exception>(
    () async {
      // Some async operation that might fail
      return 'Data fetched successfully';
    },
    (error) => Exception('Failed to fetch data: $error'),
  );
  
  // Chain async operations
  final fetchNumber = () async => Success<int, Exception>(10);
  final processNumber = (int number) async => 
      Success<String, Exception>('Processed number: $number');
      
  final processedResult = await fetchNumber().flatMapAsync(processNumber);
  print(processedResult.getOrThrow()); // Processed number: 10
}
```

### Safe error handling

```dart
import 'package:kib_utils/kib_utils.dart';

void main() {
  // Try a computation that might throw
  final divideResult = tryResult<double, Exception>(
    () => 10 / 0, // This will throw
    (error) => Exception('Division error: $error'),
  );
  
  // Safe value extraction
  final value = divideResult.getOrElse(0.0);
  print(value); // 0.0
  
  // Check result state
  if (divideResult.isSuccess) {
    print('Division succeeded with: ${divideResult.valueOrNull}');
  } else if (divideResult.isFailure) {
    print('Division failed with: ${divideResult.errorOrNull}');
  }
}
```

## Additional information

This package is meant to be a collection of essential utils. Feel free to contribute with issues, feature requests, and pull requests!