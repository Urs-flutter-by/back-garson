import 'package:back_garson/data/sources/database.dart';

void main() async {
  // Get the singleton instance and initialize it
  final db = DatabaseSource.instance..initialize();

  // Get the pool
  final pool = db.pool;

  // Test the connection with a simple query
  try {
    final result = await pool.execute('SELECT 1');
    if (result.isNotEmpty) {
      // print('Database connection successful!');
    } else {
      // print('Database connection test failed.');
    }
  } catch (e) {
    // print('Database connection error: $e');
  } finally {
    // Close the pool
    await db.close();
  }
}
