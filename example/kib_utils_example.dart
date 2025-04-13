import 'package:kib_utils/kib_utils.dart';

Future<void> main() async {
  // Success example
  final successResult = success<String, Exception>('Operation completed');
  print(successResult);  // Output: Success(Operation completed)
  
  // Failure example
  final failureResult = failure<String, Exception>(Exception('Something went wrong'));
  print(failureResult);  // Output: Failure(Exception: Something went wrong)

  // Using tryResult
  final computation = tryResult<int, Exception>(
    () => 42,
    (error) => Exception('Computation failed: $error'),
  );
  print('Computation result: ${computation.getOrElse(0)}');  // Output: Computation result: 42
  
  // Using tryResultAsync
  final asyncResult = await tryResultAsync<String, Exception>(
    () async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 'Async operation completed';
    },
    (error) => Exception('Async operation failed: $error'),
  );
  
  // Using fold to handle both success and failure
  final message = asyncResult.fold(
    (value) => 'Success: $value',
    (error) => 'Error: ${error.toString()}',
  );
  print(message);  // Output: Success: Async operation completed
}