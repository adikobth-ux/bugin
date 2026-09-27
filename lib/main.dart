import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/app.dart';
import 'package:bugin/services/app_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(BuginApp(services: AppServices.mock()));
}
