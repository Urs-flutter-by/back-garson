import 'package:back_garson/domain/entities/table.dart';
import 'package:back_garson/domain/repositories/table_repository.dart';


//класс TableService, который является посредником между слоем presentation
// (эндпоинты) и слоем domain (репозитории).
// Сервисный слой упрощает взаимодействие между эндпоинтами и репозиториями,
// добавляя бизнес-логику (например, проверки или преобразования),
// если она нужна. В данном случае он просто вызывает метод репозитория.

class TableService {
  final TableRepository repository;

  TableService(this.repository);

  Future<Table> getTableById(String id) async {
    return repository.getTableById(id);
  }
}