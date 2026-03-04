import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env file not found, use default values
    try {
      await dotenv.load();
    } catch (_) {
      // Continue without .env
    }
  }

  runApp(const CatTinderApp());
}
