import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soundsalike/constants/router_config.dart';
import 'package:soundsalike/features/recording/presentation/bloc/record_bloc.dart';
import 'package:soundsalike/services/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env before anything else — API_URL must be available at startup
  await dotenv.load(fileName: '.env');
  dependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<RecordBloc>()),
      ],
      child: MaterialApp.router(
        title: 'SoundsAlike',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF12827A),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: createRouter(),
      ),
    );
  }
}