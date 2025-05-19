import 'package:back_garson/application/services/menu_service.dart';
import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/application/services/table_service.dart';
import 'package:back_garson/data/repositories/menu_repository_impl.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:back_garson/data/repositories/table_repository_impl.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:dart_frog/dart_frog.dart';

// Handler middleware(Handler handler) {
//   return (context) async {
//     // Создаём зависимости вручную
//     final db = DatabaseSource();
//     final tableService = TableService(TableRepositoryImpl(db));
//     final orderService = OrderService(OrderRepositoryImpl(db));
//     final menuService = MenuService(MenuRepositoryImpl(db));
//
//     // Добавляем заголовки CORS
//     final corsHeaders = {
//       'Access-Control-Allow-Origin': '*',
//       'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
//       'Access-Control-Allow-Headers':
//           'Origin, Content-Type, Accept, Authorization',
//     };
//
//     // Обрабатываем запросы OPTIONS (предварительные запросы для CORS)
//     if (context.request.method == HttpMethod.options) {
//       return Response(headers: corsHeaders);
//     }
//
//     // Предоставляем зависимости
//     final updatedContext = context
//         .provide<TableService>(() => tableService)
//         .provide<OrderService>(() => orderService)
//         .provide<MenuService>(() => menuService);
//
//     // Выполняем запрос и добавляем заголовки CORS в ответ
//     final response = await handler(updatedContext);
//     return response.copyWith(
//       headers: {...response.headers, ...corsHeaders},
//     );
//   };
// }


Handler middleware(Handler handler) {
  return (context) async {
    final db = DatabaseSource();
    final tableService = TableService(TableRepositoryImpl(db));
    final orderService = OrderService(OrderRepositoryImpl(db));
    final menuService = MenuService(MenuRepositoryImpl(db));

    final corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
    };

    if (context.request.method == HttpMethod.options) {
      return Response(headers: corsHeaders);
    }

    final updatedContext = context
        .provide<TableService>(() => tableService)
        .provide<OrderService>(() => orderService)
        .provide<MenuService>(() => menuService);

    final response = await handler(updatedContext);
    return response.copyWith(
      headers: {...response.headers, ...corsHeaders},
    );
  };
}