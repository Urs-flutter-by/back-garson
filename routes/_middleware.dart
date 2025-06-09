import 'package:back_garson/application/services/menu_service.dart';
import 'package:back_garson/application/services/order_service.dart';
import 'package:back_garson/application/services/restaurant_service.dart';
import 'package:back_garson/application/services/restaurant_theme_service.dart';
import 'package:back_garson/application/services/shift_service.dart';
import 'package:back_garson/application/services/table_service.dart';
import 'package:back_garson/application/services/waiter_request_service.dart';
import 'package:back_garson/application/services/waiter_service.dart';
import 'package:back_garson/data/repositories/menu_repository_impl.dart';
import 'package:back_garson/data/repositories/order_repository_impl.dart';
import 'package:back_garson/data/repositories/restaurant_repository_impl.dart';
import 'package:back_garson/data/repositories/restaurant_theme_repository_impl.dart';
import 'package:back_garson/data/repositories/shift_repository_impl.dart';
import 'package:back_garson/data/repositories/table_repository_impl.dart';
import 'package:back_garson/data/repositories/waiter_repository_iml.dart';
import 'package:back_garson/data/repositories/waiter_request_repository_impl.dart';
import 'package:back_garson/data/sources/database.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final db = DatabaseSource();
    final tableService = TableService(TableRepositoryImpl(db));
    final orderService = OrderService(OrderRepositoryImpl(db));
    final menuService = MenuService(MenuRepositoryImpl(db));
    final waiterRequestService =
        WaiterRequestService(WaiterRequestRepositoryImpl(db));
    final restaurantService = RestaurantService(RestaurantRepositoryImpl(db));
    final restaurantThemeService =
        RestaurantThemeService(RestaurantThemeRepositoryImpl(db));
    final waiterService = WaiterService(WaiterRepositoryImpl(db));
    final shiftService = ShiftService(ShiftRepositoryImpl(db));

    //final

    final corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers':
          'Origin, Content-Type, Accept, Authorization',
    };

    if (context.request.method == HttpMethod.options) {
      //print('🔍 Middleware: Обработка OPTIONS запроса');
      return Response(headers: corsHeaders);
    }

    //print('🔍 Middleware: Предоставление зависимостей в контекст');
    final updatedContext = context
        //   .provide<DatabaseSource>(() => db) ????
        .provide<DatabaseSource>(() => db)
        .provide<TableService>(() => tableService)
        .provide<OrderService>(() => orderService)
        .provide<MenuService>(() => menuService)
        .provide<WaiterRequestService>(() => waiterRequestService)
        .provide<RestaurantService>(() => restaurantService)
        .provide<RestaurantThemeService>(() => restaurantThemeService)
        .provide<WaiterService>(() => waiterService)
        .provide<ShiftService>(() => shiftService);

    //print('🔍 Middleware: Выполнение handler');
    final response = await handler(updatedContext);
    // Логируем ответ
    print('${DateTime.now()}: Response status: ${response.statusCode}');
    return response.copyWith(
      headers: {...response.headers, ...corsHeaders},
    );
  };
}
