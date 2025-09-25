import 'dart:io'; // used to work with directories (Directory)
import 'package:path_provider/path_provider.dart'; // getApplicationDocumentsDirectory()
import 'package:sqflite/sqflite.dart'; // sqflite package for SQLite
import 'package:path/path.dart' as p; // path helper for joining paths

/// DatabaseHelper: A simple SQLite helper using `sqflite`.
/// Step-by-step comments below explain each part.
class DatabaseHelper {
  // --- Step 0: single cached Database instance (lazy initialized)
  static Database? _database;

  // Name of the table used in this database
  static const String tableName = "DatabaseTable";

  // --- Step 1: Singleton pattern so the app uses a single DB instance.
  // This prevents opening multiple database connections.
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  // --- Step 2: Public getter to obtain database instance (lazy init).
  // If the DB is already opened, return it; otherwise initialize it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    // _database is null -> initialize DB
    _database = await _initDB();
    return _database!;
  }

  // --- Step 3: Initialize the database file and open a connection.
  // 3.1: Get a safe location for storing app data (application documents dir).
  // 3.2: Build the full path for the DB file using `path.join`.
  // 3.3: Call openDatabase with version and onCreate to create tables.
  Future<Database> _initDB() async {
    // Get the directory for storing application files on device
    Directory dir = await getApplicationDocumentsDirectory();

    // Construct the full path to the database file
    String path = p.join(dir.path, 'mydatabase.db');

    // Open the database, set version, and create tables if necessary.
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // onCreate runs only if the DB file did not exist before.
        // Create your table here. You can add more fields or tables as needed.
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT, -- primary key auto increment
            title TEXT,                          -- title column (string)
            description TEXT,                    -- description column (string)
            time TEXT                            -- time column (string, store ISO or formatted)
          )
        ''');
      },
    );
  }

  // ----------------------
  // CRUD OPERATIONS
  // ----------------------

  // CREATE
  // Step 4: Insert a row into the table.
  // - Accepts a Map<String, dynamic> where keys match column names.
  // - Returns the inserted row id (int).
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // db.insert handles SQL escaping for you; it returns the new row id.
    return await db.insert(tableName, row);
  }

  // READ
  // Step 5: Query all rows from the table.
  // - Returns a List of Maps where each Map corresponds to a row.
  // - `orderBy: "id DESC"` returns latest rows first.
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(tableName, orderBy: "id DESC");
  }

  // UPDATE
  // Step 6: Update an existing row.
  // - Expects the `row` to include its `id` field.
  // - Returns number of rows affected (should be 1 for successful update).
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id']; // make sure 'id' exists in the provided map
    return await db.update(tableName, row, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE
  // Step 7: Delete a row by id.
  // - Returns number of rows deleted (should be 1 for successful delete).
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Step 8 (optional but recommended): Close the database when no longer needed.
  // - Call this when your app is shutting down or you want to free resources.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

/// ----------------------
/// EXAMPLE USAGE (commented)
/// ----------------------
///
/// // Insert example:
/// // final id = await DatabaseHelper.instance.insert({
/// //   'title': 'Buy groceries',
/// //   'description': 'Milk, Eggs, Bread',
/// //   'time': DateTime.now().toIso8601String(),
/// // });
///
/// // Query example:
/// // final rows = await DatabaseHelper.instance.queryAll();
///
/// // Update example:
/// // var rowToUpdate = rows.first;
/// // rowToUpdate['title'] = 'Updated title';
/// // await DatabaseHelper.instance.update(rowToUpdate);
///
/// // Delete example:
/// // await DatabaseHelper.instance.delete(id);
///
/// // Close DB when done (optional):
/// // await DatabaseHelper.instance.close();
