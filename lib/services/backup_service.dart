import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:kioske/data/database_helper.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // List of tables to backup, in order of dependency (if any), though restore will handle FKs if deferred or ordered correctly.
  // Ideally, we restore independence tables first.
  final List<String> _tables = [
    'users',
    'categories',
    'products',
    'customers',
    'suppliers',
    'employees', // depends on users
    'orders', // depends on customers, users(cashier)
    'expenses', // depends on users
    'deliveries', // depends on orders, customers
    'promotions', // depends on products, categories
    // 'activities', // Logic might not need restore, but good for audit. depends on users.
    'stock_movements', // depends on products, suppliers, orders, users
    'settings',
    'supply_deliveries', // depends on suppliers
    'supply_delivery_items', // depends on supply_deliveries, products
  ];

  /// Generate a JSON backup of the entire database
  Future<String?> createBackup() async {
    try {
      final db = await _dbHelper.database;
      final Map<String, dynamic> backupData = {};

      // Meta data
      backupData['meta'] = {
        'version': 1,
        'created_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0', // Could get from package_info
      };

      // Table data
      for (final table in _tables) {
        final List<Map<String, dynamic>> rows = await db.query(table);
        backupData[table] = rows;
      }

      final jsonString = jsonEncode(backupData);

      // Save file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName:
            'kioske_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        // Add extension if missing (Linux sometimes doesn't add it)
        if (!outputFile.endsWith('.json')) {
          outputFile += '.json';
        }

        final file = File(outputFile);
        await file.writeAsString(jsonString);
        return outputFile;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Restore database from a JSON backup file with merge logic
  Future<Map<String, dynamic>> restoreBackup() async {
    final result = <String, dynamic>{
      'success': false,
      'details': <String, String>{},
    };

    try {
      final FilePickerResult? pick = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (pick == null || pick.files.single.path == null) {
        result['message'] = 'No file selected';
        return result;
      }

      final file = File(pick.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      // Validate backup format
      if (!backupData.containsKey('meta')) {
        throw Exception('Invalid backup format: Missing metadata');
      }

      final db = await _dbHelper.database;

      int totalInserted = 0;
      int totalUpdated = 0;
      int totalSkipped = 0;

      await db.transaction((txn) async {
        // We iterate through our known tables list to ensure order and security
        // (ignoring unknown tables in the JSON)
        for (final table in _tables) {
          if (backupData.containsKey(table)) {
            final List<dynamic> rows = backupData[table];
            int tableInserted = 0;
            int tableUpdated = 0;
            int tableSkipped = 0;

            for (final row in rows) {
              if (row is Map<String, dynamic>) {
                final id = row['id'];
                if (id == null) continue; // Skip if no ID

                // Check existing
                final List<Map<String, dynamic>> existing = await txn.query(
                  table,
                  where: 'id = ?',
                  whereArgs: [id],
                );

                if (existing.isEmpty) {
                  // Insert
                  await txn.insert(table, row);
                  tableInserted++;
                } else {
                  // Merge logic
                  final existingRow = existing.first;

                  // Check updated_at if available
                  // If backup row has updated_at and it's newer than existing, update.
                  // If both lack updated_at, maybe prefer backup? Or skip?
                  // Strategy: If 'updated_at' exists in both, compare.
                  // If 'updated_at' exists in backup but not existing, update.
                  // If backup has no 'updated_at', skip (assume existing is simpler to keep or equal).

                  bool shouldUpdate = false;

                  if (row.containsKey('updated_at') &&
                      row['updated_at'] != null) {
                    final backupUpdate = DateTime.tryParse(
                      row['updated_at'].toString(),
                    );

                    if (backupUpdate != null) {
                      if (existingRow['updated_at'] != null) {
                        final existingUpdate = DateTime.tryParse(
                          existingRow['updated_at'].toString(),
                        );
                        if (existingUpdate != null &&
                            backupUpdate.isAfter(existingUpdate)) {
                          shouldUpdate = true;
                        }
                      } else {
                        // Existing has no update time, backup does. Assume backup is newer/better.
                        shouldUpdate = true;
                      }
                    }
                  } else {
                    // Fallback for tables without updated_at (e.g. settings might use it, but some join tables might not)
                    // If content is different? Hard to say.
                    // Let's assume simpler merge: overwrite if different? No, too risky.
                    // "If there are new data when he is restoring it should just merge with the existing one"
                    // implies adding new records. For existing, let's look at the specific requirement:
                    // "merge with existing one" -> usually means adds.
                    // But if I restored a backup from yesterday, I don't want to overwrite today's work.
                    // So only strictly newer backup records should overwrite.
                    shouldUpdate = false;
                  }

                  if (shouldUpdate) {
                    await txn.update(
                      table,
                      row,
                      where: 'id = ?',
                      whereArgs: [id],
                    );
                    tableUpdated++;
                  } else {
                    tableSkipped++;
                  }
                }
              }
            }

            result['details'][table] =
                'Inserted: $tableInserted, Updated: $tableUpdated, Skipped: $tableSkipped';
            totalInserted += tableInserted;
            totalUpdated += tableUpdated;
            totalSkipped += tableSkipped;
          }
        }
      });

      result['success'] = true;
      result['message'] =
          'Restore complete. Inserted: $totalInserted, Updated: $totalUpdated, Skipped: $totalSkipped';
      return result;
    } catch (e) {
      result['success'] = false;
      result['message'] = 'Restore failed: $e';
      return result;
    }
  }
}
