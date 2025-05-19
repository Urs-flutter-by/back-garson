import 'package:back_garson/data/sources/database.dart';

void main() async {
  final db = DatabaseSource();
  final conn = await db.connection;
  print('Connected to database!');
  await db.close();
}