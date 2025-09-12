import 'package:flutter_test/flutter_test.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';
import '../support/fake_app_repository.dart';

void main() {
  group('AppsUseCase', () {
    test('create + list', () async {
      final repo = FakeAppRepository();
      final uc = AppsUseCase(repo);
      expect((await uc.list()).length, 0);
      final created = await uc.create(
        name: 'App1',
        url: Uri.parse('https://a.example'),
      );
      final list = await uc.list();
      expect(list.length, 1);
      expect(list.first.id, created.id);
    });

    test('update', () async {
      final repo = FakeAppRepository();
      final uc = AppsUseCase(repo);
      final created = await uc.create(
        name: 'Old',
        url: Uri.parse('https://old.example'),
      );
      final updated = await uc.update(
        id: created.id,
        name: 'New',
        url: Uri.parse('https://new.example'),
      );
      expect(updated.name, 'New');
      final fetched = await uc.get(created.id);
      expect(fetched!.name, 'New');
    });

    test('delete', () async {
      final repo = FakeAppRepository();
      final uc = AppsUseCase(repo);
      final created = await uc.create(
        name: 'Temp',
        url: Uri.parse('https://temp.example'),
      );
      await uc.delete(created.id);
      final all = await uc.list();
      expect(all, isEmpty);
    });

    test('update non-existent throws', () async {
      final repo = FakeAppRepository();
      final uc = AppsUseCase(repo);
      expect(
        () => uc.update(
          id: 'nope',
          name: 'X',
          url: Uri.parse('https://x.example'),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
