import 'package:back_garson/domain/entities/table.dart';
import 'package:back_garson/domain/repositories/table_repository.dart';

/// Сервис, отвечающий за бизнес-логику, связанную со столами.
///
/// Этот сервис является посредником между слоем представления (эндпоинты)
/// и слоем данных, используя [TableRepository] для получения данных о столах
/// и возвращая их в виде сущностей [Table].
class TableService {
  /// Создает экземпляр [TableService].
  ///
  /// Требует репозиторий [TableRepository], который реализует
  /// интерфейс из `lib/domain/repositories/table_repository.dart`.
  TableService(this.repository);

  /// Репозиторий для доступа к данным о столах.
  final TableRepository repository;

  /// Получает информацию о столе по его [id].
  ///
  /// Возвращает [Future] с сущностью [Table]
  /// из `lib/domain/entities/table.dart`.
  Future<Table> getTableById(String id) async {
    return repository.getTableById(id);
  }
}
