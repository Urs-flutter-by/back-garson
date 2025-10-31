import 'package:back_garson/presentation/middleware/authentication_middleware.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(authenticationMiddleware());
}
