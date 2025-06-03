import 'package:equatable/equatable.dart';


//Класс Equatable (из пакета equatable) позволяет сравнивать объекты по их
// свойствам, а не по ссылкам в памяти. Это полезно для проверки равенства
// двух объектов Table (например, table1 == table2) и для работы с тестами или
// реактивными фреймворками. Без Equatable пришлось бы вручную переопределять
// методы == и hashCode.

///Определяет сущность Table — это чистая модель данных
class Table extends Equatable {
  final String id;
  final String status;
  final int capacity;
  final int number;
  final String  restaurantId;

  const Table({
    required this.id,
    required this.status,
    required this.capacity,
    required this.number,
    required this.restaurantId,
  });

  @override
  List<Object?> get props => [id, status, capacity, number, restaurantId];
}
