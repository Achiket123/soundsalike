import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:soundsalike/constants/router_config.dart';
import 'package:soundsalike/features/recording/presentation/bloc/record_bloc.dart';
import 'package:soundsalike/services/dependency_injection.dart';

final GetIt getIt = GetIt.instance;
void main() async {
  dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  dependencyInjection();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => getIt<RecordBloc>())],
      child: MaterialApp.router(routerConfig: createRouter()),
    );
  }
}
