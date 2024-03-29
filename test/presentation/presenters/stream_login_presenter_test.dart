import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tdd_clean_architecture/domain/entities/account_entity.dart';
import 'package:tdd_clean_architecture/domain/helpers/helpers.dart';
import 'package:tdd_clean_architecture/domain/usecases/usecases.dart';

import 'package:tdd_clean_architecture/presentation/presenters/presenters.dart';
import 'package:tdd_clean_architecture/presentation/protocols/protocols.dart';

class ValidationSpy extends Mock implements Validation {}

class AuthenticationSpy extends Mock implements Authentication {}

void main() {
  late StreamLoginPresenter sut;
  late AuthenticationSpy authentication;
  late ValidationSpy validation;
  late String email;
  late String password;

  When mockValidationCall(String? field) => when((() => validation.validate(
      field: field ?? any(named: 'field'), value: any(named: 'value'))));

  void mockValidation({String? field, String? value}) {
    mockValidationCall(field).thenReturn(value);
  }

  When mockAuthenticationCall() =>
      when(() => authentication.auth(AuthenticationParams(
          email: faker.internet.email(), secret: faker.internet.password())));

  void mockAuthentication() {
    mockAuthenticationCall()
        .thenAnswer((_) async => AccountEntity(faker.guid.guid()));
  }

  void mockAuthenticationError(DomainError error) =>
      mockAuthenticationCall().thenThrow(error);

  setUp(() {
    validation = ValidationSpy();
    authentication = AuthenticationSpy();
    sut = StreamLoginPresenter(
        validation: validation, authentication: authentication);
    email = faker.internet.email();
    password = faker.internet.password();
    mockValidation();
    mockAuthentication();
  });

  test('should call Validation with correct email', () {
    sut.validateEmail(email);

    verify(() => validation.validate(field: 'email', value: email)).called(1);
  });

  test('should emit email error if validation fails', () {
    mockValidation(value: 'error');

    sut.emailErrorStream!
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream!
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email);
    sut.validateEmail(email);
  });

  test('should emit null error if validation succeeds', () {
    sut.emailErrorStream!.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream!
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email);
    sut.validateEmail(email);
  });

  test('should call Validation with correct password', () {
    sut.validatePassword(password);

    verify(() => validation.validate(field: 'password', value: password))
        .called(1);
  });

  test('should emit null if validation password is succees', () {
    mockValidation(value: 'error');

    sut.passwordErrorStream!
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream!
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validatePassword(password);
    sut.validatePassword(password);
  });

  test('should emit password error if validation fails', () {
    mockValidation(field: 'email', value: 'error');

    sut.emailErrorStream!
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.passwordErrorStream!
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream!
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email);
    sut.validatePassword(password);
  });

  test('should emits true in FormValidation if password and email is valid',
      () async {
    sut.emailErrorStream!.listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream!
        .listen(expectAsync1((error) => expect(error, null)));
    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateEmail(email);
    await Future.delayed(Duration.zero);
    sut.validatePassword(password);
  });

  test('should call Authentication with correct values', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    await sut.auth();

    verify(() => authentication
        .auth(AuthenticationParams(email: email, secret: password))).called(1);
  });

  test('should emit correct events on Authentication success', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    await sut.auth();
  });

  test('should emit correct events on invalidCredentialsError', () async* {
    mockAuthenticationError(DomainError.invalidCredentials);
    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    // expectLater(sut.mainErrorStream, emitsInOrder([null, 'Credenciais inválidas.']));
    sut.mainErrorStream?.listen(
        expectAsync1((error) => expect(error, 'Credenciais inválidas.')));

    await sut.auth();
  });

  test('should emit correct events on UnexpextedError', () async* {
    // mockAuthenticationError(DomainError.unexpected);
    mockAuthenticationCall().thenThrow(DomainError.unexpected);
    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    // expectLater(sut.mainErrorStream, emitsInOrder([null, 'Credenciais inválidas.']));
    // expectLater(sut.mainErrorStream, emitsInOrder([null, 'Algo errado aconteceu. Tente novamente em breve.']));

    sut.mainErrorStream?.listen(expectAsync1((error) {
      print(error);
      expect(error, 'Algo errado aconteceu. Tente novamente em breve.');
    }),
    );

    await sut.auth();
  });

  test('should not emit after dispose', () async {
    expectLater(sut.emailErrorStream, neverEmits(null));
    sut.dispose();
    sut.validateEmail(email);

    // expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    // // expectLater(sut.mainErrorStream, emitsInOrder([null, 'Credenciais inválidas.']));
    // sut.mainErrorStream.listen(expectAsync1((error) =>
    //     expect(error, 'Algo errado aconteceu. Tente novamente em breve.')));

    // await sut.auth();
  });
}
