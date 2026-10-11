import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

Future<NativeDatabase> openDriftConnection() async {
	final folder = await getApplicationSupportDirectory();
	final file = File(path.join(folder.path, 'viper_scout.db'));
	return NativeDatabase(file, logStatements: true);
}
