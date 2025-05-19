import 'package:back_garson/utils/config.dart';
import 'package:postgres/postgres.dart';

//класс DatabaseSource для управления подключением к PostgreSQL.
//Этот класс отвечает за создание и закрытие соединения с базой данных.
// Он используется в table_repository_impl.dart для выполнения запросов

class DatabaseSource {
  DatabaseSource() {
    _connection = Connection.open(
      Endpoint(
        host: Config.dbHost,
        port: Config.dbPort,
        database: Config.dbName,
        username: Config.dbUser,
        password: Config.dbPassword,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  late Future<Connection> _connection;

  Future<Connection> get connection async => await _connection;

  Future<void> close() async {
    final conn = await _connection;
    await conn.close();
  }
}