import 'package:flutter_test/flutter_test.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';
import '../support/fake_app_repository.dart';

void main() {
  test('create then list returns the app', () async {
    final repo = FakeAppRepository();
    final useCase = AppsUseCase(repo);

    final created = await useCase.create(
      name: 'Sample',
      url: Uri.parse('https://example.com'),
    );

    final apps = await useCase.list();
    expect(apps.length, 1);
    expect(apps.first.id, created.id);
    expect(apps.first.name, 'Sample');
  });
}
