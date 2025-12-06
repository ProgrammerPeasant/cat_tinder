# Cat Tinder – Архитектура и навигация

## Источники данных
- **TheCatAPI** (`https://api.thecatapi.com/v1`)
  - `/images/search` – получение случайного изображения кота вместе с данными о породе.
  - `/breeds` – каталог пород, используем для таба «Список пород» и для детальных описаний.

## Слой данных
- `CatImage` – id, url, width, height, `breed` (опциональный `CatBreed`)
- `CatBreed` – id, name, origin, description, temperament, life span, intelligence, adaptability и т д
- `CatApiClient` – отвечает за низкоуровневые HTTP-запросы. Методы:
  - `Future<List<CatImage>> fetchRandomCats({int limit = 1})`
  - `Future<List<CatBreed>> fetchBreeds()`
- `CatRepository` – бизнес-логика:
  - `Future<CatImage> getRandomCat()`
  - `Future<List<CatBreed>> getBreeds()`

## Состояние и менеджмент
- Используется `ChangeNotifier` + `Provider`.
- `SwipeDeckController` - хранит текущего кота, счетчик лайков, обрабатывает свайпы и кнопки.
- `BreedsController` – хранит список пород и состояние загрузки/ошибок.
- Общая модель “UI state”: `enum LoadState { idle, loading, error }`.
- Ошибки обрабатываются централизованным `ErrorHandler`, который возвращает человекочитаемое сообщение и триггерит показ диалога (`showErrorDialog`).

## Навигация
- Корневой `MaterialApp` с темой в стиле Tinder (градиенты, розово-оранжевый акцент, кастомный шрифт `Sora`).
- Нижний таб-бар (`BottomNavigationBar`) с двумя вкладками:
  1. **Swipe** – главный экран с карточкой кота, кнопками лайк/дизлайк, счетчиком.
  2. **Breeds** – список пород.
- Детальные экраны открываются через `Navigator.push`:
  - `CatDetailsPage` – по тапу на карточку кота; показывает фото и полный набор характеристик породы.
  - `BreedDetailsPage` – по тапу на элемент списка пород.

## UI-компоненты
- `CatCard` – карточка с изображением (`CachedNetworkImage`), названием породы и индикаторами свайпа
- `SwipeActions` – две круглые кнопки с тенями
- `BreedsListTile` – факты о породе
