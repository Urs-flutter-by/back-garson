import 'package:back_garson/domain/entities/table.dart';

/// Абстрактный репозиторий для работы со столами.
///
/// Определяет контракт для получения данных о столах.
// ignore: one_member_abstracts
abstract class TableRepository {
  /// Получает информацию о столе по его [id].
  ///
  /// Возвращает [Future] с объектом [Table].
  Future<Table> getTableById(String id);
}
