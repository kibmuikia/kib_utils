import 'package:kib_utils/kib_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success', () {
      final result = Success<int, Exception>(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, 42);
      expect(result.getOrThrow(), 42);
    });

    test('Failure', () {
      final error = Exception('Test error');
      final result = Failure<int, Exception>(error);
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, error);
    });

    test('map', () {
      final result = Success<int, Exception>(42);
      final mappedResult = result.map((value) => value.toString());
      expect(mappedResult.isSuccess, true);
      expect(mappedResult.valueOrNull, '42');
    });

    test('flatMapAsync', () async {
      Future<Result<int, Exception>> fetchNumber() async => Success(10);
      Future<Result<String, Exception>> fetchString(int number) async =>
          Success('Number: $number');
      final flatMappedResult = await fetchNumber().flatMapAsync(fetchString);
      expect(flatMappedResult.isSuccess, true);
      expect(flatMappedResult.getOrThrow(), 'Number: 10');
    });

    test('tryResult', () {
      final result = tryResult<int, Exception>(
          () => 42, (error) => Exception('Test error'));
      expect(result.isSuccess, true);
      expect(result.getOrThrow(), 42);
    });

    test('tryResult with error', () {
      final result = tryResult<int, Exception>(
        () => throw Exception('Test error'),
        (error) => error,
      );
      expect(result.isFailure, true);
      expect(result.valueOrNull, isNull);
    });

    test('tryResultAsync', () async {
      final result = await tryResultAsync<int, Exception>(
          () async => 42, (error) => Exception('Test error'));
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.getOrThrow(), 42);
    });
    
    test('tryResultAsync with error', () async {
      final testError = Exception('Test error');
      final result = await tryResultAsync<int, Exception>(
          () async => throw testError, (error) => testError);
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.valueOrNull, isNull);
    });
  });
}
