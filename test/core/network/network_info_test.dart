import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'network_info_test.mocks.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([DataConnectionChecker])
void main() {
  late MockDataConnectionChecker mockDataConnectionChecker; // is this sut ?!
  late NetworkInfoImpl networkInfo;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfoImpl(connectionChecker: mockDataConnectionChecker);
  });

  group('isConnected', () {
    test(
      'should forward the call to DataConnectionChecker.hasConnection',
      () async {
        // arrange
        final tHasConnectionFuture = Future.value(true);
        when(
          mockDataConnectionChecker.hasConnection,
        ).thenAnswer((_) => tHasConnectionFuture); // WE ARE

        // act
        final result = networkInfo.isConnected;

        // assert
        verify(mockDataConnectionChecker.hasConnection);
        expect(result, tHasConnectionFuture);
      },
    );
  });
}
