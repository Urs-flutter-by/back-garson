// lib/application/services/hall_service.dart
import 'package:back_garson/data/models/hall_model.dart';
import 'package:back_garson/domain/repositories/hall_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную с залами.
///
/// Этот сервис использует [HallRepository] для получения данных о залах
/// и возвращает их в виде моделей [HallModel].
class HallService {
  /// Создает экземпляр [HallService].
  ///
  /// Требует репозиторий [HallRepository], который реализует
  /// интерфейс из `lib/domain/repositories/hall_repository.dart`.
  HallService(this.repository);

  /// Репозиторий для доступа к данным о залах.
  final HallRepository repository;

  /// Получает все залы, связанные с указанным [restaurantId].
  ///
  /// Возвращает [Future] со списком [HallModel]
  /// из `lib/data/models/hall_model.dart`.
  Future<List<HallModel>> getHallsByRestaurantId(String restaurantId) async {
    return repository.getHallsByRestaurantId(restaurantId);
  }
}
