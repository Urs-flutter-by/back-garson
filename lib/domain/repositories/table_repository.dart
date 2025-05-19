import 'package:back_garson/domain/entities/table.dart';

//Определяет абстрактный интерфейс TableRepository с методами для работы
// со столиками (например, getTableById). Этот интерфейс описывает,
// какие операции должны быть доступны для работы со столиками,
// но не реализует их. Это позволяет легко заменить реализацию
// (например, поменять PostgreSQL на другую базу данных) без изменения
// остального кода.


abstract class TableRepository {
  Future<Table> getTableById(String id);
}