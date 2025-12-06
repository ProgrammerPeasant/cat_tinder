# Cat Tinder

Приложение для любителей котиков. Данные берутся из [TheCatAPI](https://thecatapi.com/), изображения подгружаются через `CachedNetworkImage`

## APK

- [Cat Tinder v1.0.0 (release)](artifacts/cat_tinder-v1.0.0.apk)

## Фичи

- Случайная анкета кота с фото, названием и страной происхождения породы
- Управление свайпом или кнопками, счётчик лайков обновляется мгновенно
- Предзагрузка 4 следующих анкет, чтобы не было пауз между свайпами.
- Тап по карточке открывает детальный экран с описанием и характеристиками породы
- Нижний таб-бар: второй экран показывает список всех пород и отдельную карточку с 3‑4 ключевыми характеристиками
- Градиентная тема, кастомные шрифты, стеклянный таб-бар
- Обработка сетевых ошибок с диалогом и кнопко + CORS-прокси для веба

## Архитектура

- **Data**: `CatApiClient` на `dio`, модели `CatImage`/`CatBreed`, репозиторий с in-memory кешем пород.
- **State**: `ChangeNotifier` (Provider). `SwipeController` хранит очередь анкет и счётчик лайков, `BreedsController` управляет списком пород.
- **UI**: два экрана внутри `BottomNavigationBar`, reusable карточки, диалоги ошибок, тема вынесена в `core/ui/app_theme.dart`.
- Подробности в [`docs/architecture.md`](docs/architecture.md).

## Как запустить

```bash
git clone <repo>
cd cat_tinder
flutter pub get
flutter run
```

## Чтоб проверить кода

```bash
dart format lib test
flutter analyze
flutter test
```

- `lib/app.dart` – точка входа UI и таб-бар
- `lib/features/swipe/` – свайпы, детали анкеты, очередь котов
- `lib/features/breeds/` – список пород и детали
- `docs/architecture.md` – схема приложения

