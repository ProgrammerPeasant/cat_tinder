import 'package:cat_tinder/core/load_state.dart';
import 'package:cat_tinder/data/models/cat_breed.dart';
import 'package:cat_tinder/data/models/cat_image.dart';
import 'package:cat_tinder/data/repositories/cat_repository.dart';
import 'package:cat_tinder/features/swipe/swipe_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatRepository extends Mock implements CatRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SwipeController', () {
    late _MockCatRepository repository;
    late SwipeController controller;

    setUp(() {
      repository = _MockCatRepository();
      controller = SwipeController(repository);

      when(() => repository.getRandomCats(limit: any(named: 'limit'))).thenAnswer((invocation) async {
        final limit = invocation.namedArguments[#limit] as int? ?? 4;
        return List.generate(limit, (index) {
          return CatImage(
            id: 'cat-$index',
            url: 'https://example.com/$index.jpg',
            width: 600,
            height: 800,
            breed: CatBreed(
              id: 'abys',
              name: 'Abyssinian',
              origin: 'Egypt',
              description: 'Agile and friendly',
              temperament: 'Active',
              lifeSpan: '12-15',
              intelligence: 5,
              adaptability: 5,
              wikipediaUrl: null,
            ),
          );
        });
      });
    });

    test('increments likes and preloads next cat', () async {
      await controller.init();
      final firstId = controller.currentCat?.id;

      await controller.like();

      expect(controller.likes, 1);
      expect(controller.currentCat?.id, isNot(firstId));
      expect(controller.state, LoadState.idle);
    });
  });
}
