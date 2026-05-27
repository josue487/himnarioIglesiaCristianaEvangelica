import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'services/settings_service.dart';
import 'screens/main_screen.dart';

// Set to true only after running `flutterfire configure` and adding google-services.json
const _kCrashlyticsEnabled = false;

Future<void> _initCrashlytics() async {
  if (!_kCrashlyticsEnabled) return;
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initCrashlytics();
  final service = SettingsService();
  final initial = await service.load();
  runApp(HimnarioApp(initialSettings: initial, service: service));
}

class HimnarioApp extends StatelessWidget {
  final SettingsState initialSettings;
  final SettingsService service;

  const HimnarioApp({
    super.key,
    required this.initialSettings,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(service, initialSettings),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Himnario ICE',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                surface: settings.backgroundColor,
              ),
              scaffoldBackgroundColor: settings.backgroundColor,
              useMaterial3: true,
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
