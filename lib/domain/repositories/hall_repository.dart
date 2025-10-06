// lib/domain/repositories/hall_repository.dart
import 'package:back_garson/data/models/hall_model.dart';

/// Абстрактный репозиторий для работы с залами.
///
/// Определяет контракт для получения данных о залах.
// ignore: one_member_abstracts
abstract class HallRepository {
  /// Получает все залы, связанные с указанным [restaurantId].
  ///
  /// Возвращает [Future] со списком [HallModel].
  Future<List<HallModel>> getHallsByRestaurantId(String restaurantId);
}
